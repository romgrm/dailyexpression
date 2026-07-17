import 'package:daily_expression/domain/models/cefr_level.dart';
import 'package:daily_expression/domain/models/concept.dart';
import 'package:daily_expression/domain/models/language_pair.dart';
import 'package:daily_expression/domain/models/register.dart';
import 'package:daily_expression/domain/use_cases/get_daily_expression.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/in_memory_daily_log.dart';

/// Minimal concept — the selector only reads [Concept.id], so forms/glosses can
/// stay empty here.
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

void main() {
  group('GetDailyExpression', () {
    test('same seed, day and pool always pick the same concept', () async {
      final day = DateTime(2026, 7, 17);
      final pool = _pool(8);

      Future<String> resolve() async {
        final usecase = GetDailyExpression(
          log: InMemoryDailyLog(),
          clock: FakeClock(day),
          userSeed: 'seed-A',
        );
        return (await usecase(pair: _pair, pool: pool)).id;
      }

      expect(await resolve(), await resolve());
    });

    test('different seeds can produce different streams', () async {
      final day = DateTime(2026, 7, 17);
      final pool = _pool(8);

      Future<String> resolveWith(String seed) async {
        final usecase = GetDailyExpression(
          log: InMemoryDailyLog(),
          clock: FakeClock(day),
          userSeed: seed,
        );
        return (await usecase(pair: _pair, pool: pool)).id;
      }

      final picks = <String>{};
      for (final seed in ['a', 'b', 'c', 'd', 'e', 'f']) {
        picks.add(await resolveWith(seed));
      }
      expect(picks.length, greaterThan(1));
    });

    test('a logged day is returned unchanged on re-resolve (idempotent)',
        () async {
      final clock = FakeClock(DateTime(2026, 7, 17));
      final log = InMemoryDailyLog();
      final usecase =
          GetDailyExpression(log: log, clock: clock, userSeed: 'seed-A');

      final first = await usecase(pair: _pair, pool: _pool(8));
      final second = await usecase(pair: _pair, pool: _pool(8));

      expect(second.id, first.id);
      expect(log.entries.length, 1);
    });

    test('frozen replay: a logged day keeps its concept even as the pool grows',
        () async {
      final clock = FakeClock(DateTime(2026, 7, 17));
      final log = InMemoryDailyLog();
      final usecase =
          GetDailyExpression(log: log, clock: clock, userSeed: 'seed-A');

      final first = await usecase(pair: _pair, pool: _pool(8));
      // Corpus grows: extra concepts appended, original id still present.
      final grown = await usecase(pair: _pair, pool: _pool(12));

      expect(grown.id, first.id);
      expect(log.entries.length, 1);
    });

    test('midnight rollover assigns a new day', () async {
      final clock = FakeClock(DateTime(2026, 7, 17, 23, 59));
      final log = InMemoryDailyLog();
      final usecase =
          GetDailyExpression(log: log, clock: clock, userSeed: 'seed-A');

      await usecase(pair: _pair, pool: _pool(8));
      clock.current = DateTime(2026, 7, 18, 0, 1);
      await usecase(pair: _pair, pool: _pool(8));

      final history = await log.history('en_fr');
      expect(history.length, 2);
      expect(history[0].dayKey, '2026-07-17');
      expect(history[1].dayKey, '2026-07-18');
    });

    test('no repeats until the pool is exhausted', () async {
      final clock = FakeClock(DateTime(2026, 1, 1));
      final log = InMemoryDailyLog();
      final usecase =
          GetDailyExpression(log: log, clock: clock, userSeed: 'seed-A');
      final pool = _pool(8);

      final picks = <String>[];
      for (var i = 0; i < 8; i++) {
        clock.current = DateTime(2026, 1, 1).add(Duration(days: i));
        picks.add((await usecase(pair: _pair, pool: pool)).id);
      }

      expect(picks.toSet().length, 8, reason: 'all 8 concepts seen once');
    });

    test('after exhaustion, reshuffle avoids the most recent concepts',
        () async {
      final clock = FakeClock(DateTime(2026, 1, 1));
      final log = InMemoryDailyLog();
      final usecase =
          GetDailyExpression(log: log, clock: clock, userSeed: 'seed-A');
      final pool = _pool(8);

      final picks = <String>[];
      for (var i = 0; i < 9; i++) {
        clock.current = DateTime(2026, 1, 1).add(Duration(days: i));
        picks.add((await usecase(pair: _pair, pool: pool)).id);
      }

      final lastThreeBeforeDay9 = picks.sublist(5, 8).toSet();
      expect(lastThreeBeforeDay9.contains(picks[8]), isFalse);
    });

    test('throws when the pool is empty', () async {
      final usecase = GetDailyExpression(
        log: InMemoryDailyLog(),
        clock: FakeClock(DateTime(2026, 7, 17)),
        userSeed: 'seed-A',
      );

      expect(
        () => usecase(pair: _pair, pool: const []),
        throwsStateError,
      );
    });
  });
}
