import 'package:daily_expression/data/repositories/prefs_daily_log_repository.dart';
import 'package:daily_expression/domain/models/daily_assignment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

DailyAssignment _entry(String dayKey, String conceptId, {String pair = 'en_fr'}) =>
    DailyAssignment(
      dayKey: dayKey,
      conceptId: conceptId,
      pairKey: pair,
      assignedAt: DateTime.parse('${dayKey}T08:00:00Z'),
    );

void main() {
  late PrefsDailyLogRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = PrefsDailyLogRepository(await SharedPreferences.getInstance());
  });

  test('saves and reads back an assignment for a day', () async {
    await repo.save(_entry('2026-07-17', 'rain_heavy'));

    final found = await repo.forDay('2026-07-17', 'en_fr');
    expect(found?.conceptId, 'rain_heavy');
    expect(found?.schemaVersion, 1);
  });

  test('forDay is scoped to the pair', () async {
    await repo.save(_entry('2026-07-17', 'rain_heavy', pair: 'en_fr'));

    expect(await repo.forDay('2026-07-17', 'en_es'), isNull);
  });

  test('save is idempotent per (dayKey, pairKey)', () async {
    await repo.save(_entry('2026-07-17', 'rain_heavy'));
    await repo.save(_entry('2026-07-17', 'very_expensive'));

    final history = await repo.history('en_fr');
    expect(history.length, 1);
    expect(history.single.conceptId, 'very_expensive');
  });

  test('history is filtered by pair and ordered by day ascending', () async {
    await repo.save(_entry('2026-07-19', 'c', pair: 'en_fr'));
    await repo.save(_entry('2026-07-17', 'a', pair: 'en_fr'));
    await repo.save(_entry('2026-07-18', 'x', pair: 'en_es'));

    final frHistory = await repo.history('en_fr');
    expect(frHistory.map((e) => e.dayKey).toList(), ['2026-07-17', '2026-07-19']);
  });

  test('survives a new repository instance (persisted)', () async {
    await repo.save(_entry('2026-07-17', 'rain_heavy'));

    final reopened =
        PrefsDailyLogRepository(await SharedPreferences.getInstance());
    expect((await reopened.forDay('2026-07-17', 'en_fr'))?.conceptId,
        'rain_heavy');
  });
}
