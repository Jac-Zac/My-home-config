import Carbon
func strProp(_ s: TISInputSource, _ k: CFString) -> String {
  guard let p = TISGetInputSourceProperty(s, k) else { return "" }
  return Unmanaged<CFString>.fromOpaque(p).takeUnretainedValue() as String
}
func boolProp(_ s: TISInputSource, _ k: CFString) -> Bool {
  guard let p = TISGetInputSourceProperty(s, k) else { return false }
  return Unmanaged<CFBoolean>.fromOpaque(p).takeUnretainedValue() == kCFBooleanTrue
}
let args = CommandLine.arguments
let mode = args.count > 1 ? args[1] : "list"
if mode == "current" {
  if let cur = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() {
    print(strProp(cur, kTISPropertyInputSourceID))
  }
} else if mode == "set", args.count > 2 {
  let all = (TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource]) ?? []
  if let t = all.first(where: { strProp($0, kTISPropertyInputSourceID) == args[2] }) {
    print(TISSelectInputSource(t) == noErr ? "ok" : "fail")
  } else { print("not-found") }
} else {
  let all = (TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource]) ?? []
  for s in all {
    if strProp(s, kTISPropertyInputSourceCategory) == (kTISCategoryKeyboardInputSource as String)
      && boolProp(s, kTISPropertyInputSourceIsEnabled) {
      print("\(strProp(s, kTISPropertyInputSourceID))\t\(strProp(s, kTISPropertyLocalizedName))")
    }
  }
}
