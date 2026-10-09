// Events for the calendar popup. Reads Apple Calendar (EventKit) directly — icalBuddy reports the last day of multi-day all-day events one day short.
//   events <YYYY-MM-01> [calendarID,…] → (unused by the bar, kept for scripting) every event touching that month, by start. One line each: "date<TAB>text<TAB>kind"
//   Date: single day 09.23 · multi-day (even across months) 09.23-09.26 — always the real start and end dates
//   kind: "h" for holiday calendars (subscribed/holiday/birthday), "" otherwise
// Calendars synced into macOS (Google accounts behind Notion Calendar, iCloud, Exchange…) all come through EventKit.
// Access: TCC grants Calendar to the *responsible* process (sketchybar), keyed by its binary path — a brew upgrade
// changes that path and silently drops the grant. So ask when undetermined (macOS shows the prompt for sketchybar),
// and exit 2 when denied so the popup can say so instead of looking empty.
import EventKit
import Foundation

let s = EKEventStore()

func authorized() -> Bool {
  let st = EKEventStore.authorizationStatus(for: .event)
  if #available(macOS 14.0, *) { if st == .fullAccess { return true } }
  if st == .authorized { return true }
  guard st == .notDetermined else { return false }
  let sem = DispatchSemaphore(value: 0)
  var ok = false
  if #available(macOS 14.0, *) {
    s.requestFullAccessToEvents { g, _ in ok = g; sem.signal() }
  } else {
    s.requestAccess(to: .event) { g, _ in ok = g; sem.signal() }
  }
  _ = sem.wait(timeout: .now() + 60)
  return ok
}

let a = CommandLine.arguments
guard authorized() else { FileHandle.standardError.write("denied\n".data(using: .utf8)!); exit(2) }

func isHoliday(_ c: EKCalendar) -> Bool {
  if c.type == .birthday { return true }
  let t = c.title.lowercased()
  return ["holiday", "festiv", "feiertag", "férié", "feriados"].contains { t.contains($0) }
}
// Cancelled, or an invite you declined: Google keeps those in the calendar ("deleting" an invite in Notion
// Calendar / Google declines it), so EventKit still returns them — hide them like Notion Calendar does
func gone(_ e: EKEvent) -> Bool {
  e.status == .canceled || e.attendees?.first(where: { $0.isCurrentUser })?.participantStatus == .declined
}

//   events refresh                     → ask macOS to sync calendar accounts now (Google only syncs on an interval,
//                                         so events just made in Notion Calendar lag). Prints "changed" if the store
//                                         changed within 10 s, so the caller knows to redraw. Exits on first change.
if a.count > 1 && a[1] == "refresh" {
  let obs = NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: s, queue: .main) { _ in
    print("changed"); exit(0)
  }
  s.refreshSourcesIfNecessary()
  RunLoop.main.run(until: Date().addingTimeInterval(10))
  NotificationCenter.default.removeObserver(obs)
  exit(0)
}
//   events watch "<command>"           → run the command whenever the calendar store changes (an event added,
//                                         edited or deleted locally, or a sync bringing that in). Stays running;
//                                         bursts are coalesced into one run. Exits when SketchyBar is gone
if a.count > 2 && a[1] == "watch" {
  let cmd = a[2]
  var pending: DispatchWorkItem?
  NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: s, queue: .main) { _ in
    pending?.cancel()
    let w = DispatchWorkItem { let t = Process(); t.launchPath = "/bin/sh"; t.arguments = ["-c", cmd]; try? t.run() }
    pending = w
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: w)
  }
  Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in   // no orphans
    let t = Process(); t.launchPath = "/usr/bin/pgrep"; t.arguments = ["-x", "sketchybar"]; try? t.run(); t.waitUntilExit()
    if t.terminationStatus != 0 { exit(0) }
  }
  RunLoop.main.run()
}

let d = DateFormatter(); d.dateFormat = "yyyy-MM-dd"
//   events today [name|name…]          → what's left today (ongoing + upcoming, all-day first), by start.
//                                         "HH:mm<TAB>title<TAB>kind<TAB>start<TAB>end" (epochs; start 0 = all day).
//                                         All-day events get "all day". Names filter calendars by title
if a.count > 1 && a[1] == "today" {
  let cal = Calendar.current, now = Date()
  let st = cal.startOfDay(for: now), en = cal.date(byAdding: .day, value: 1, to: st)!
  let names = a.count > 2 ? Set(a[2].split(separator: "|").map(String.init)) : []
  let cals = names.isEmpty ? nil : s.calendars(for: .event).filter { names.contains($0.title) }
  if cals?.isEmpty == true { exit(0) }
  let hm = DateFormatter(); hm.dateFormat = "HH:mm"
  var seen = Set<String>()  // the same event shared into two calendars shows once
  for e in s.events(matching: s.predicateForEvents(withStart: st, end: en, calendars: cals))
      .filter({ ($0.isAllDay || $0.endDate > now) && !gone($0) })
      .sorted(by: { ($0.isAllDay ? 0 : 1, $0.startDate) < ($1.isAllDay ? 0 : 1, $1.startDate) }) {
    let when = e.isAllDay ? "all day" : (e.startDate <= now ? "now" : hm.string(from: e.startDate))
    let title = (e.title ?? "").replacingOccurrences(of: "\t", with: " ").replacingOccurrences(of: "\n", with: " ")
    if !seen.insert(when + title).inserted { continue }
    print("\(when)\t\(title)\t\(isHoliday(e.calendar) ? "h" : "")\t\(e.isAllDay ? 0 : Int(e.startDate.timeIntervalSince1970))\t\(Int(e.endDate.timeIntervalSince1970))")
  }
  exit(0)
}
//   events days <YYYY-MM-01> [name|name…] → two lines for the month grid: "ev 3 9 12 …" (days with events)
//                                         and "hol 4 12" (days covered by holiday calendars). Names filter calendars by title
if a.count > 2 && a[1] == "days" {
  let cal = Calendar.current
  guard let from = d.date(from: a[2]) else { exit(1) }
  let to = cal.date(byAdding: .month, value: 1, to: from)!
  let names = a.count > 3 ? Set(a[3].split(separator: "|").map(String.init)) : []
  let cals = names.isEmpty ? nil : s.calendars(for: .event).filter { names.contains($0.title) }
  var ev = Set<Int>(), hol = Set<Int>()
  if cals?.isEmpty != true {
    for e in s.events(matching: s.predicateForEvents(withStart: from, end: to, calendars: cals)) where !gone(e) {
      // an all-day end is 23:59 that day; a timed event ending at midnight belongs to the day before
      var day = max(cal.startOfDay(for: e.startDate), from)
      let last = min(cal.startOfDay(for: e.endDate.addingTimeInterval(e.isAllDay ? 0 : -1)), cal.date(byAdding: .day, value: -1, to: to)!)
      while day <= last {
        if isHoliday(e.calendar) { hol.insert(cal.component(.day, from: day)) } else { ev.insert(cal.component(.day, from: day)) }
        day = cal.date(byAdding: .day, value: 1, to: day)!
      }
    }
  }
  print("ev " + ev.sorted().map(String.init).joined(separator: " "))
  print("hol " + hol.sorted().map(String.init).joined(separator: " "))
  exit(0)
}
//   events calid <calendar name>       → ID of the calendar with that name (e.g. US Holidays)
if a.count > 2 && a[1] == "calid" {
  for c in s.calendars(for: .event) where c.title == a[2] { print(c.calendarIdentifier); exit(0) }
  exit(1)
}
guard a.count > 1, let from = d.date(from: a[1]) else { exit(1) }
let cal = Calendar.current
let to = cal.date(byAdding: .month, value: 1, to: from)!
let ids = a.count > 2 ? Set(a[2].split(separator: ",").map(String.init)) : []
let cals = ids.isEmpty ? nil : s.calendars(for: .event).filter { ids.contains($0.calendarIdentifier) }
let md = DateFormatter(); md.dateFormat = "MM.dd"
let hm = DateFormatter(); hm.dateFormat = "HH:mm"
for e in s.events(matching: s.predicateForEvents(withStart: from, end: to, calendars: cals)).sorted(by: { $0.startDate < $1.startDate }) {
  // An all-day event's end arrives as 23:59 that day. A timed event ending at midnight counts up to the day before
  let last = cal.startOfDay(for: e.endDate.addingTimeInterval(e.isAllDay ? 0 : -1))
  let first = cal.startOfDay(for: e.startDate)
  var key = md.string(from: first)
  if last > first { key += "-" + md.string(from: last) }
  let t = e.isAllDay ? "" : hm.string(from: e.startDate) + " "
  let title = (e.title ?? "").replacingOccurrences(of: "\t", with: " ").replacingOccurrences(of: "\n", with: " ")
  print("\(key)\t\(t)\(title)\t\(isHoliday(e.calendar) ? "h" : "")")
}
