// Events for the calendar popup. Reads Apple Calendar (EventKit) directly — icalBuddy reports the last day of multi-day all-day events one day short.
//   events <YYYY-MM-01> [calendarID,…] → every event touching that month, by start. One line each: "date<TAB>text"
//   Date: single day 09.23 · multi-day (even across months) 09.23-09.26 — always the real start and end dates
import EventKit
let a = CommandLine.arguments
let d = DateFormatter(); d.dateFormat = "yyyy-MM-dd"
//   events today                       → today's timed events that haven't ended yet (including ongoing), all calendars, by start. "HH:mm<TAB>title"
if a.count > 1 && a[1] == "today" {
  let s = EKEventStore(), cal = Calendar.current, now = Date()
  let st = cal.startOfDay(for: now), en = cal.date(byAdding: .day, value: 1, to: st)!
  let hm = DateFormatter(); hm.dateFormat = "HH:mm"
  for e in s.events(matching: s.predicateForEvents(withStart: st, end: en, calendars: nil))
      .filter({ !$0.isAllDay && $0.endDate > now }).sorted(by: { $0.startDate < $1.startDate }) {
    print("\(hm.string(from: e.startDate))\t\(e.title ?? "")")
  }
  exit(0)
}
//   events calid <calendar name>       → ID of the calendar with that name (e.g. US Holidays)
if a.count > 2 && a[1] == "calid" {
  for c in EKEventStore().calendars(for: .event) where c.title == a[2] { print(c.calendarIdentifier); exit(0) }
  exit(1)
}
guard a.count > 1, let from = d.date(from: a[1]) else { exit(1) }
let cal = Calendar.current
let to = cal.date(byAdding: .month, value: 1, to: from)!
let ids = a.count > 2 ? Set(a[2].split(separator: ",").map(String.init)) : []
let s = EKEventStore()
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
  print("\(key)\t\(t)\(e.title ?? "")")
}
