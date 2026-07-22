import '../models/streak_state.dart';

/// Pure streak transition, applied exactly once per app open. Given the
/// previous [StreakState] and the current time [now]:
/// - same local calendar day as the last counted open -> unchanged (idempotent,
///   so re-opening or a cubit rebuild the same day never double-counts);
/// - exactly the next calendar day -> count + 1;
/// - a gap of two or more days, or the very first open -> reset to 1.
/// The day boundary is the device's local calendar day, matching the daily card
/// and the reminders.
StreakState nextStreak(StreakState previous, DateTime now) {
  final today = _dateOnly(now);
  final last = previous.lastOpenedDay;
  if (last == null) {
    return previous.copyWith(count: 1, lastOpenedDay: today);
  }
  final gap = _dayNumber(today) - _dayNumber(last);
  if (gap == 0) return previous;
  final count = gap == 1 ? previous.count + 1 : 1;
  return previous.copyWith(count: count, lastOpenedDay: today);
}

DateTime _dateOnly(DateTime dateTime) {
  final local = dateTime.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// A DST-proof calendar-day ordinal: project the local date onto UTC midnight
/// (UTC days are always 24h) and count whole days since the epoch, so
/// consecutive-day math is never off-by-one on daylight-saving boundaries.
int _dayNumber(DateTime localDate) =>
    DateTime.utc(localDate.year, localDate.month, localDate.day)
            .millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
