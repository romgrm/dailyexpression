import 'package:daily_expression/domain/models/streak_state.dart';
import 'package:daily_expression/domain/use_cases/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first ever open starts the streak at 1', () {
    final result = nextStreak(const StreakState(), DateTime(2026, 7, 22, 9));

    expect(result.count, 1);
    expect(result.lastOpenedDay, DateTime(2026, 7, 22));
  });

  test('opening again the same day leaves the streak unchanged', () {
    final previous = StreakState(count: 5, lastOpenedDay: DateTime(2026, 7, 22));

    final result = nextStreak(previous, DateTime(2026, 7, 22, 23, 59));

    expect(result, previous);
  });

  test('opening the next day increments the streak', () {
    final previous = StreakState(count: 5, lastOpenedDay: DateTime(2026, 7, 22));

    final result = nextStreak(previous, DateTime(2026, 7, 23, 6));

    expect(result.count, 6);
    expect(result.lastOpenedDay, DateTime(2026, 7, 23));
  });

  test('a gap of two or more days resets the streak to 1', () {
    final previous = StreakState(count: 9, lastOpenedDay: DateTime(2026, 7, 22));

    final result = nextStreak(previous, DateTime(2026, 7, 25, 8));

    expect(result.count, 1);
    expect(result.lastOpenedDay, DateTime(2026, 7, 25));
  });

  test('consecutive days across a month boundary keep incrementing', () {
    final previous = StreakState(count: 3, lastOpenedDay: DateTime(2026, 7, 31));

    final result = nextStreak(previous, DateTime(2026, 8, 1, 7));

    expect(result.count, 4);
    expect(result.lastOpenedDay, DateTime(2026, 8, 1));
  });
}
