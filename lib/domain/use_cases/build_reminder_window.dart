import '../models/concept.dart';
import '../models/daily_assignment.dart';
import '../models/language_pair.dart';
import '../time/clock.dart';
import 'daily_selection.dart';

/// One planned reminder: the local instant it should fire and the concept whose
/// idiom it will tease. The wiring layer localizes the title/body from
/// [concept] before handing it to the notification service.
typedef ReminderSlot = ({DateTime scheduledAt, Concept concept});

/// Builds the next [count] daily reminder slots for [pair], each carrying the
/// concept the card will reveal that day.
///
/// Each day is resolved through the shared [selectConceptForDay] against the
/// CURRENT [history] frozen (no per-day simulation): because history only
/// changes when the app is opened — which also triggers a reschedule — the
/// imminent notification always matches the concept the next open will assign.
class BuildReminderWindow {
  const BuildReminderWindow({required Clock clock, required String userSeed})
      : _clock = clock,
        _userSeed = userSeed;

  final Clock _clock;
  final String _userSeed;

  List<ReminderSlot> call({
    required LanguagePair pair,
    required List<Concept> pool,
    required List<DailyAssignment> history,
    required int reminderHour,
    required int reminderMinute,
    int count = 14,
  }) {
    if (pool.isEmpty || count <= 0) return const [];

    final now = _clock.now().toLocal();
    final pairKey = pair.glossKey;

    // First slot is today if the reminder time is still ahead, else tomorrow.
    var first = DateTime(
      now.year,
      now.month,
      now.day,
      reminderHour,
      reminderMinute,
    );
    if (!first.isAfter(now)) {
      first = first.add(const Duration(days: 1));
    }

    final slots = <ReminderSlot>[];
    for (var i = 0; i < count; i++) {
      // Adding to the day component lets DateTime normalise month/year rollover.
      final at = DateTime(
        first.year,
        first.month,
        first.day + i,
        reminderHour,
        reminderMinute,
      );
      final concept = selectConceptForDay(
        pool: pool,
        history: history,
        pairKey: pairKey,
        dayKey: dayKeyOf(at),
        userSeed: _userSeed,
      );
      slots.add((scheduledAt: at, concept: concept));
    }
    return slots;
  }
}
