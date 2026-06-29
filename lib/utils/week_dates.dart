// Shared week-boundary helpers.
//
// The app treats a week as running SUNDAY 00:00 → SATURDAY 23:59 in the
// device's LOCAL time. This is the boundary the weekly-goals checklist resets
// on and the boundary the planner-insights week selector pages by, so the two
// features agree on what "this week" means.
//
// (The planner-insights trend CHARTS keep their own multi-week bucketing — see
// planner_insights_screen.dart — but their selected-week math routes through
// here too, so the cards and the goal reset never drift apart.)

/// Local midnight at the start of the Sunday-led week containing [d].
///
/// `DateTime.weekday` is Mon=1 … Sun=7, so `weekday % 7` is the number of days
/// since the most recent Sunday (Sunday→0, Monday→1, … Saturday→6). Subtracting
/// that from local midnight lands exactly on Sunday 00:00 local.
DateTime startOfWeekSunday(DateTime d) {
  final localMidnight = DateTime(d.year, d.month, d.day);
  return localMidnight.subtract(Duration(days: localMidnight.weekday % 7));
}

/// Exclusive end of the Sunday-led week containing [d] — i.e. the following
/// Sunday 00:00 local. A timestamp `t` is in the week iff
/// `!t.isBefore(start) && t.isBefore(end)`.
DateTime endOfWeekSunday(DateTime d) =>
    startOfWeekSunday(d).add(const Duration(days: 7));

/// True when [a] and [b] fall in the same Sunday-led local week.
bool sameWeekSunday(DateTime a, DateTime b) =>
    startOfWeekSunday(a) == startOfWeekSunday(b);

/// Compact `yyyy-MM-dd` key for the Sunday that starts the week containing [d].
/// Used as the persisted stamp that tells the weekly-goals toggle store whether
/// a new week has begun since it was last written.
String weekKeySunday(DateTime d) {
  final s = startOfWeekSunday(d);
  return '${s.year}-${s.month.toString().padLeft(2, '0')}-'
      '${s.day.toString().padLeft(2, '0')}';
}
