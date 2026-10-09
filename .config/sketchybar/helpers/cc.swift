// Control Center helper: state + toggles the CLI doesn't expose.
//   cc status             → "wifi=1 bt=1 dark=1 bright=63 kbd=40" (display / keyboard backlight %, -1 if none,
//                            kbd=auto while automatic keyboard brightness is on)
//   cc bt on|off          → Bluetooth power (the private IOBluetooth calls blueutil uses)
//   cc bright <0-100>     → built-in display brightness (DisplayServices, as the brightness keys do)
//   cc kbd <0-100>        → keyboard backlight (CoreBrightness KeyboardBrightnessClient, as the F-keys do)
//   cc stats              → "cpu=12 mem=61 memgb=14.6 memtotal=24 disk=46 diskfree=260" — the Activity Monitor
//                            numbers: CPU from per-core tick deltas over 300ms, memory = app + wired + compressed,
//                            disk free = "available for important usage" (what Finder shows, purgeable counts as free)
// Wi-Fi power and dark mode are read here too, but switched from Lua with networksetup / System Events.
import CoreGraphics
import CoreWLAN
import Foundation
import IOBluetooth

@_silgen_name("IOBluetoothPreferenceGetControllerPowerState") func btGet() -> Int32
@_silgen_name("IOBluetoothPreferenceSetControllerPowerState") func btSet(_ state: Int32)

// DisplayServices is private and has no headers: resolve the two symbols at runtime
typealias GetB = @convention(c) (CGDirectDisplayID, UnsafeMutablePointer<Float>) -> Int32
typealias SetB = @convention(c) (CGDirectDisplayID, Float) -> Int32
let ds = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_LAZY)
func sym<T>(_ name: String, _: T.Type) -> T? {
  guard let ds, let p = dlsym(ds, name) else { return nil }
  return unsafeBitCast(p, to: T.self)
}

func builtinDisplay() -> CGDirectDisplayID? {
  var ids = [CGDirectDisplayID](repeating: 0, count: 8); var n: UInt32 = 0
  CGGetOnlineDisplayList(8, &ids, &n)
  return ids.prefix(Int(n)).first { CGDisplayIsBuiltin($0) != 0 }
}

func brightness() -> Int {
  guard let d = builtinDisplay(), let get = sym("DisplayServicesGetBrightness", GetB.self) else { return -1 }
  var v: Float = 0
  return get(d, &v) == 0 ? Int((v * 100).rounded()) : -1
}

// Keyboard backlight: private ObjC class with float args, so call the method IMPs directly.
// Auto-brightness pins the level to ambient light (0 in daylight), so a manual set turns auto off — like
// dragging the slider in System Settings. "kbd=auto" in status while auto is on.
let kbd: (client: NSObject, id: UInt64)? = {
  guard dlopen("/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness", RTLD_LAZY) != nil,
        let cls = NSClassFromString("KeyboardBrightnessClient") as? NSObject.Type else { return nil }
  let c = cls.init()
  guard let ids = c.perform(NSSelectorFromString("copyKeyboardBacklightIDs"))?.takeRetainedValue() as? [NSNumber],
        let id = ids.first else { return nil }
  return (c, id.uint64Value)
}()
func kcall<T>(_ name: String, _: T.Type) -> (T, Selector, NSObject, UInt64)? {
  guard let k = kbd else { return nil }
  let sel = NSSelectorFromString(name)
  return (unsafeBitCast(class_getMethodImplementation(type(of: k.client), sel), to: T.self), sel, k.client, k.id)
}
func kbdStatus() -> String {
  typealias Get = @convention(c) (AnyObject, Selector, UInt64) -> Float
  typealias Auto = @convention(c) (AnyObject, Selector, UInt64) -> Bool
  guard let (get, gs, c, id) = kcall("brightnessForKeyboard:", Get.self),
        let (auto, asel, _, _) = kcall("isAutoBrightnessEnabledForKeyboard:", Auto.self) else { return "-1" }
  return auto(c, asel, id) ? "auto" : String(Int((get(c, gs, id) * 100).rounded()))
}
func kbdSet(_ v: Float) {
  typealias Enable = @convention(c) (AnyObject, Selector, Bool, UInt64) -> Bool
  typealias Set = @convention(c) (AnyObject, Selector, Float, Int32, Bool, UInt64) -> Bool
  guard let (en, es, c, id) = kcall("enableAutoBrightness:forKeyboard:", Enable.self),
        let (set, ss, _, _) = kcall("setBrightness:fadeSpeed:commit:forKeyboard:", Set.self) else { return }
  _ = en(c, es, false, id)
  _ = set(c, ss, max(0, min(100, v)) / 100, 0, true, id)
}

func cpuTicks() -> (busy: UInt64, total: UInt64) {
  var count: natural_t = 0, info: processor_info_array_t?, n: mach_msg_type_number_t = 0
  guard host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &count, &info, &n) == KERN_SUCCESS, let info else { return (0, 0) }
  defer { vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), vm_size_t(Int(n) * MemoryLayout<integer_t>.size)) }
  var busy: UInt64 = 0, total: UInt64 = 0
  for c in 0..<Int(count) {
    let b = c * Int(CPU_STATE_MAX)
    let user = UInt64(info[b + Int(CPU_STATE_USER)]), sys = UInt64(info[b + Int(CPU_STATE_SYSTEM)])
    let nice = UInt64(info[b + Int(CPU_STATE_NICE)]), idle = UInt64(info[b + Int(CPU_STATE_IDLE)])
    busy += user + sys + nice; total += user + sys + nice + idle
  }
  return (busy, total)
}

func stats() -> String {
  let t0 = cpuTicks(); usleep(300_000); let t1 = cpuTicks()
  let dt = t1.total &- t0.total
  let cpu = dt > 0 ? Int((Double(t1.busy &- t0.busy) / Double(dt) * 100).rounded()) : 0

  var vm = vm_statistics64(), sz = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
  _ = withUnsafeMutablePointer(to: &vm) { $0.withMemoryRebound(to: integer_t.self, capacity: Int(sz)) { host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &sz) } }
  let page = Double(vm_kernel_page_size), total = Double(ProcessInfo.processInfo.physicalMemory)
  let app = Double(vm.internal_page_count) - Double(vm.purgeable_count)  // Activity Monitor's "App Memory"
  let used = (app + Double(vm.wire_count) + Double(vm.compressor_page_count)) * page
  let mem = Int((used / total * 100).rounded())

  let vol = URL(fileURLWithPath: "/")
  let r = try? vol.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey])
  let dtot = Double(r?.volumeTotalCapacity ?? 0), dfree = Double(r?.volumeAvailableCapacityForImportantUsage ?? 0)
  let disk = dtot > 0 ? Int(((dtot - dfree) / dtot * 100).rounded()) : 0
  return String(format: "cpu=%d mem=%d memgb=%.1f memtotal=%.0f disk=%d diskfree=%.0f",
                cpu, mem, used / 1_073_741_824, total / 1_073_741_824, disk, dfree / 1_000_000_000)
}

let a = CommandLine.arguments
switch a.count > 1 ? a[1] : "" {
case "status":
  let wifi = CWWiFiClient.shared().interface()?.powerOn() == true ? 1 : 0
  let g = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
  let dark = (g?["AppleInterfaceStyle"] as? String) == "Dark" ? 1 : 0
  print("wifi=\(wifi) bt=\(btGet() == 1 ? 1 : 0) dark=\(dark) bright=\(brightness()) kbd=\(kbdStatus())")
case "bt" where a.count > 2:
  btSet(a[2] == "on" ? 1 : 0)
case "bright" where a.count > 2:
  guard let v = Float(a[2]), let d = builtinDisplay(), let set = sym("DisplayServicesSetBrightness", SetB.self) else { exit(1) }
  _ = set(d, max(0, min(100, v)) / 100)
case "stats":
  print(stats())
case "kbd" where a.count > 2:
  guard let v = Float(a[2]) else { exit(1) }
  kbdSet(v)
default:
  print("usage: cc status | stats | bt on|off | bright <0-100> | kbd <0-100>"); exit(1)
}
