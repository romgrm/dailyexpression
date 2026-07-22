import 'package:daily_expression/domain/models/cefr_level.dart';
import 'package:daily_expression/domain/models/concept.dart';
import 'package:daily_expression/domain/models/language_pair.dart';
import 'package:daily_expression/domain/models/register.dart';
import 'package:daily_expression/domain/time/clock.dart';
import 'package:daily_expression/domain/use_cases/plan_daily_reminders.dart';
import 'package:daily_expression/domain/use_cases/daily_selection.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

Concept _concept(String id) => Concept(
      id: id,
      category: 'weather',
      level: CefrLevel.b1,
      register: Register.neutral,
      meaning: const {},
      forms: const {},
      glosses: const {},
      tags: const [],
    );

List<Concept> _pool(int n) =>
    List.generate(n, (i) => _concept('c${i.toString().padLeft(2, '0')}'));

const _pair = LanguagePair(native: 'fr', target: 'en');

PlanDailyReminders _build(Clock clock) =>
    PlanDailyReminders(clock: clock, userSeed: 'seed-A');

void main() {
  group('PlanDailyReminders', () {
    test('returns exactly [days] daily reminders on consecutive days', () {
      final clock = FakeClock(DateTime(2026, 7, 17, 6));
      final slots = _build(clock)(
        pair: _pair,
        pool: _pool(8),
        history: const [],
        reminderHour: 8,
        reminderMinute: 0,
        days: 14,
      );

      expect(slots.length, 14);
      for (var i = 0; i < slots.length; i++) {
        expect(slots[i].scheduledAt.hour, 8);
        expect(slots[i].scheduledAt.minute, 0);
        if (i > 0) {
          expect(
            slots[i].scheduledAt.difference(slots[i - 1].scheduledAt),
            const Duration(days: 1),
          );
        }
      }
    });

    test('first slot is today when the reminder time is still ahead', () {
      final clock = FakeClock(DateTime(2026, 7, 17, 6));
      final slots = _build(clock)(
        pair: _pair,
        pool: _pool(8),
        history: const [],
        reminderHour: 8,
        reminderMinute: 0,
        days: 3,
      );
      expect(slots.first.scheduledAt, DateTime(2026, 7, 17, 8, 0));
    });

    test('first slot is tomorrow when the reminder time already passed', () {
      final clock = FakeClock(DateTime(2026, 7, 17, 9));
      final slots = _build(clock)(
        pair: _pair,
        pool: _pool(8),
        history: const [],
        reminderHour: 8,
        reminderMinute: 0,
        days: 3,
      );
      expect(slots.first.scheduledAt, DateTime(2026, 7, 18, 8, 0));
    });

    test('each slot carries the concept the card will reveal that day', () {
      final clock = FakeClock(DateTime(2026, 7, 17, 6));
      final pool = _pool(8);
      final slots = _build(clock)(
        pair: _pair,
        pool: pool,
        history: const [],
        reminderHour: 8,
        reminderMinute: 0,
        days: 14,
      );

      for (final slot in slots) {
        final expected = selectConceptForDay(
          pool: pool,
          history: const [],
          pairKey: _pair.glossKey,
          dayKey: dayKeyOf(slot.scheduledAt),
          userSeed: 'seed-A',
        );
        expect(slot.concept.id, expected.id);
      }
    });

    test('is empty for an empty pool or non-positive count', () {
      final clock = FakeClock(DateTime(2026, 7, 17, 6));
      expect(
        _build(clock)(
          pair: _pair,
          pool: const [],
          history: const [],
          reminderHour: 8,
          reminderMinute: 0,
        ),
        isEmpty,
      );
      expect(
        _build(clock)(
          pair: _pair,
          pool: _pool(8),
          history: const [],
          reminderHour: 8,
          reminderMinute: 0,
          days: 0,
        ),
        isEmpty,
      );
    });
  });
}
