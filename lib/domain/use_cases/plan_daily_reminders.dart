import '../models/concept.dart';
import '../models/daily_assignment.dart';
import '../models/language_pair.dart';
import '../time/clock.dart';
import 'daily_selection.dart';

/// One planned reminder: the local instant it should fire and the concept whose
/// idiom it will tease. The wiring layer localizes the title/body from
/// [concept] before handing it to the notification service.
typedef PlannedReminder = ({DateTime scheduledAt, Concept concept});

/// Plans the next [days] daily reminders for [pair], each carrying the concept
/// the card will reveal that day.
///
/// Each day is resolved through the shared [selectConceptForDay] against the
/// CURRENT [history] frozen (no per-day simulation): because history only
/// changes when the app is opened — which also triggers a reschedule — the
/// imminent notification always matches the concept the next open will assign.
class PlanDailyReminders {
  const PlanDailyReminders({required Clock clock, required String userSeed})
      : _clock = clock,
        _userSeed = userSeed;

  final Clock _clock;
  final String _userSeed;

  List<PlannedReminder> call({
    required LanguagePair pair,
    required List<Concept> pool,
    required List<DailyAssignment> history,
    required int reminderHour,
    required int reminderMinute,
    int days = 14,
  }) {
    if (pool.isEmpty || days <= 0) return const [];

    final now = _clock.now().toLocal();
    final pairKey = pair.glossKey;

    // First reminder is today if the time is still ahead, else tomorrow.
    var firstFireAt = DateTime(
      now.year,
      now.month,
      now.day,
      reminderHour,
      reminderMinute,
    );
    if (!firstFireAt.isAfter(now)) {
      firstFireAt = firstFireAt.add(const Duration(days: 1));
    }

    final reminders = <PlannedReminder>[];
    for (var i = 0; i < days; i++) {
      // Adding to the day component lets DateTime normalise month/year rollover.
      final fireAt = DateTime(
        firstFireAt.year,
        firstFireAt.month,
        firstFireAt.day + i,
        reminderHour,
        reminderMinute,
      );
      final concept = selectConceptForDay(
        pool: pool,
        history: history,
        pairKey: pairKey,
        dayKey: dayKeyOf(fireAt),
        userSeed: _userSeed,
      );
      reminders.add((scheduledAt: fireAt, concept: concept));
    }
    return reminders;
  }
}
