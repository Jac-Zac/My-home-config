// Click-away for popups (after sketchybar-island). Runs only while a popup is open:
// the first click outside the bar and its popups runs the given command, then it exits.
// No polling — it sleeps until a click arrives, and quits by itself after 10 minutes.
//   clickaway <shell command…>
import AppKit

let cmd = CommandLine.arguments.dropFirst().joined(separator: " ")

func insideSketchybar(_ p: CGPoint) -> Bool {
  let list = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]] ?? []
  return list.contains { w in
    guard (w[kCGWindowOwnerName as String] as? String) == "sketchybar",
          let b = w[kCGWindowBounds as String] as? NSDictionary,
          let r = CGRect(dictionaryRepresentation: b) else { return false }
    return r.contains(p)
  }
}

NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { _ in
  let m = NSEvent.mouseLocation  // Cocoa: bottom-left origin of the main screen → CG top-left
  let h = NSScreen.screens.first?.frame.height ?? 0
  if insideSketchybar(CGPoint(x: m.x, y: h - m.y)) { return }  // bar/popup clicks belong to the bar
  let t = Process()
  t.executableURL = URL(fileURLWithPath: "/bin/sh")
  t.arguments = ["-c", cmd]
  try? t.run(); t.waitUntilExit()
  exit(0)
}
DispatchQueue.main.asyncAfter(deadline: .now() + 600) { exit(0) }
NSApplication.shared.setActivationPolicy(.prohibited)
NSApplication.shared.run()
