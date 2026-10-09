// Month grid for the calendar popup, rendered as a PNG because a SketchyBar text field has one
// color and a week row needs several (after sketchybar-island's textspans helper).
//   calgrid <out.png> <year> <month> <today|0> <past-before-day|0> "<event days>" "<holiday days>"
// Header + up to 6 week rows, 26pt each, SF Mono 12 in 5-char cells (" 12  ", today "[12] "):
// Sundays + holidays red · Saturdays blue · past days dimmed · today bold in [ ] · a dot under days with events.
// Colors mirror helpers/popup.lua (Catppuccin Mocha). Drawn at 2× for Retina; the bar shows it at scale 0.5.
import AppKit

let a = CommandLine.arguments
guard a.count >= 8, let y = Int(a[2]), let m = Int(a[3]), let today = Int(a[4]), let pastBefore = Int(a[5]) else {
  print("usage: calgrid out.png year month today past-before \"ev days\" \"hol days\""); exit(1)
}
func days(_ s: String) -> Set<Int> { Set(s.split(separator: " ").compactMap { Int($0) }) }
let ev = days(a[6]), hol = days(a[7])

func rgb(_ v: UInt32) -> NSColor {
  NSColor(srgbRed: CGFloat((v >> 16) & 0xff) / 255, green: CGFloat((v >> 8) & 0xff) / 255, blue: CGFloat(v & 0xff) / 255, alpha: 1)
}
let text = rgb(0xeceff4), dim = rgb(0xa6adc8), faint = rgb(0x6c7086), red = rgb(0xf38ba8), blue = rgb(0x89b4fa)
let regular = NSFont(name: "SFMono-Regular", size: 12) ?? .monospacedSystemFont(ofSize: 12, weight: .regular)
let bold = NSFont(name: "SFMono-Bold", size: 12) ?? .monospacedSystemFont(ofSize: 12, weight: .bold)

let CW: CGFloat = 7.418, ROW: CGFloat = 26, CELL = 5
let cal = Calendar(identifier: .gregorian)
let first = cal.date(from: DateComponents(year: y, month: m, day: 1))!
let lead = cal.component(.weekday, from: first) - 1  // 0 = Sunday
let ndays = cal.range(of: .day, in: .month, for: first)!.count
let weeks = (lead + ndays + 6) / 7
let W = CGFloat(CELL * 7 - 2) * CW, H = CGFloat(weeks + 1) * ROW

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(W * 2), pixelsHigh: Int(H * 2), bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: W, height: H)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

// row 0 is the top row; Cocoa's origin is bottom-left
func draw(_ s: String, col: Int, row: Int, color: NSColor, font: NSFont = regular) {
  let str = NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: color])
  let h = str.size().height
  str.draw(at: NSPoint(x: CGFloat(col * CELL) * CW, y: H - CGFloat(row + 1) * ROW + (ROW - h) / 2))
}

for (i, n) in ["SU", "MO", "TU", "WE", "TH", "FR", "SA"].enumerated() {
  draw(" " + n, col: i, row: 0, color: i == 0 ? red : (i == 6 ? blue : dim))
}
for d in 1...ndays {
  let idx = lead + d - 1, col = idx % 7, row = idx / 7 + 1
  var c = col == 0 || hol.contains(d) ? red : (col == 6 ? blue : text)
  if d < pastBefore { c = c.blended(withFraction: 0.55, of: rgb(0x1e1e2e)) ?? faint }
  if d == today {
    draw("[", col: col, row: row, color: text)
    draw(String(format: " %2d", d), col: col, row: row, color: c, font: bold)
    draw("   ]", col: col, row: row, color: text)
  } else {
    draw(String(format: " %2d", d), col: col, row: row, color: c)
  }
  if ev.contains(d) {  // dot centered under the digits (one-digit days sit in the cell's 2nd half)
    let cx = (CGFloat(col * CELL) + (d < 10 ? 2.5 : 2)) * CW, cy = H - CGFloat(row + 1) * ROW + 3.5
    (d < pastBefore ? faint : dim).setFill()
    NSBezierPath(ovalIn: NSRect(x: cx - 1.25, y: cy - 1.25, width: 2.5, height: 2.5)).fill()
  }
}
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: a[1]))
