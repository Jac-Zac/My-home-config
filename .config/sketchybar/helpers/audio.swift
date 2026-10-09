// Output devices (CoreAudio) — nothing to install. Same source as the output list in Control Center's Sound
//   audio            → one line each: "ID<TAB>name<TAB>kind(builtin|bluetooth|other)<TAB>1 if current"
//   audio set <ID>   → change the default output device. Non-zero exit code on failure
//   audio bt         → paired but unconnected Bluetooth audio devices "address<TAB>name" (the ones Control Center lists too). Takes about 4 s, so vol.sh caches it in the background
//   audio connect <address> → connect and, once it appears as an audio device (up to 8 s), make it the default output. Non-zero exit code on failure
//   audio watch "<command>" → run the command whenever mute or the default output device changes (stays running). SketchyBar's volume_change doesn't fire for mute (keyboard mute key)
import CoreAudio
import Foundation
import IOBluetooth

func prop(_ sel: AudioObjectPropertySelector, _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> AudioObjectPropertyAddress {
  AudioObjectPropertyAddress(mSelector: sel, mScope: scope, mElement: kAudioObjectPropertyElementMain)
}
let sys = AudioObjectID(kAudioObjectSystemObject)
func defaultOut() -> AudioDeviceID {
  var a = prop(kAudioHardwarePropertyDefaultOutputDevice); var id = AudioDeviceID(0); var sz = UInt32(MemoryLayout<AudioDeviceID>.size)
  AudioObjectGetPropertyData(sys, &a, 0, nil, &sz, &id); return id
}
func u32(_ id: AudioObjectID, _ sel: AudioObjectPropertySelector) -> UInt32 {
  var a = prop(sel); var v = UInt32(0); var sz = UInt32(4); AudioObjectGetPropertyData(id, &a, 0, nil, &sz, &v); return v
}
func name(_ id: AudioObjectID) -> String {
  var a = prop(kAudioObjectPropertyName); var s: Unmanaged<CFString>?; var sz = UInt32(MemoryLayout<CFString?>.size)
  guard AudioObjectGetPropertyData(id, &a, 0, nil, &sz, &s) == noErr, let v = s?.takeRetainedValue() else { return "?" }
  return v as String
}
func outChannels(_ id: AudioObjectID) -> Int {
  var a = prop(kAudioDevicePropertyStreamConfiguration, kAudioObjectPropertyScopeOutput); var sz = UInt32(0)
  guard AudioObjectGetPropertyDataSize(id, &a, 0, nil, &sz) == noErr, sz > 0 else { return 0 }
  let buf = UnsafeMutableRawPointer.allocate(byteCount: Int(sz), alignment: 16); defer { buf.deallocate() }
  guard AudioObjectGetPropertyData(id, &a, 0, nil, &sz, buf) == noErr else { return 0 }
  return UnsafeMutableAudioBufferListPointer(buf.assumingMemoryBound(to: AudioBufferList.self)).reduce(0) { $0 + Int($1.mNumberChannels) }
}

let args = CommandLine.arguments
if args.count >= 3, args[1] == "set", var id = AudioDeviceID(args[2]) {
  var a = prop(kAudioHardwarePropertyDefaultOutputDevice)
  let r = AudioObjectSetPropertyData(sys, &a, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &id)
  exit(r == noErr && defaultOut() == id ? 0 : 1)
}
func outputs() -> [(AudioDeviceID, String, String)] {
  var a = prop(kAudioHardwarePropertyDevices); var sz = UInt32(0)
  AudioObjectGetPropertyDataSize(sys, &a, 0, nil, &sz)
  var ids = [AudioDeviceID](repeating: 0, count: Int(sz) / MemoryLayout<AudioDeviceID>.size)
  AudioObjectGetPropertyData(sys, &a, 0, nil, &sz, &ids)
  var out: [(AudioDeviceID, String, String)] = []
  for id in ids where outChannels(id) > 0 && u32(id, kAudioDevicePropertyIsHidden) == 0 {
    let t = u32(id, kAudioDevicePropertyTransportType)
    if t == kAudioDeviceTransportTypeAggregate || t == kAudioDeviceTransportTypeAutoAggregate { continue }   // hidden aggregate devices
    let kind = t == kAudioDeviceTransportTypeBuiltIn ? "builtin" : (t == kAudioDeviceTransportTypeBluetooth || t == kAudioDeviceTransportTypeBluetoothLE) ? "bluetooth" : "other"
    out.append((id, name(id), kind))
  }
  return out
}
if args.count >= 2, args[1] == "bt" {
  let live = Set(outputs().map { $0.1 })
  for d in (IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice]) ?? [] where d.deviceClassMajor == 4 && !d.isConnected() {   // 4 = audio
    if let n = d.name, !live.contains(n) { print("\(d.addressString ?? "")\t\(n)") }
  }
  exit(0)
}
if args.count >= 3, args[1] == "connect", let d = IOBluetoothDevice(addressString: args[2]) {
  guard d.openConnection() == kIOReturnSuccess else { exit(1) }
  for _ in 0..<40 {   // 0.2 s × 40 until it shows up as an audio device after connecting
    if let o = outputs().first(where: { $0.2 == "bluetooth" && $0.1 == d.name }) {
      var a = prop(kAudioHardwarePropertyDefaultOutputDevice); var id = o.0
      let r = AudioObjectSetPropertyData(sys, &a, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &id)
      exit(r == noErr ? 0 : 1)
    }
    usleep(200000)
  }
  exit(1)
}
if args.count >= 3, args[1] == "watch" {
  let cmd = args[2]
  func run() { let t = Process(); t.launchPath = "/bin/sh"; t.arguments = ["-c", cmd]; try? t.run() }
  var dev = AudioDeviceID(0)
  var muteAddr = prop(kAudioDevicePropertyMute, kAudioDevicePropertyScopeOutput)
  let onMute: AudioObjectPropertyListenerBlock = { _, _ in run() }
  func attach() {
    if dev != 0 { AudioObjectRemovePropertyListenerBlock(dev, &muteAddr, DispatchQueue.main, onMute) }
    dev = defaultOut(); AudioObjectAddPropertyListenerBlock(dev, &muteAddr, DispatchQueue.main, onMute)
  }
  attach()
  var defAddr = prop(kAudioHardwarePropertyDefaultOutputDevice)
  AudioObjectAddPropertyListenerBlock(sys, &defAddr, DispatchQueue.main) { _, _ in attach(); run() }   // when the device changes, resubscribe to the new device's mute
  Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in   // exit when SketchyBar is gone (no orphans)
    let t = Process(); t.launchPath = "/usr/bin/pgrep"; t.arguments = ["-x", "sketchybar"]; try? t.run(); t.waitUntilExit()
    if t.terminationStatus != 0 { exit(0) }
  }
  RunLoop.main.run()
}
let cur = defaultOut()
for (id, n, kind) in outputs() { print("\(id)\t\(n)\t\(kind)\t\(id == cur ? 1 : 0)") }
