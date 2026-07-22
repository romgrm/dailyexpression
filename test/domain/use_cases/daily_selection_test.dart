import 'package:daily_expression/domain/models/cefr_level.dart';
import 'package:daily_expression/domain/models/concept.dart';
import 'package:daily_expression/domain/models/daily_assignment.dart';
import 'package:daily_expression/domain/models/register.dart';
import 'package:daily_expression/domain/use_cases/daily_selection.dart';
import 'package:flutter_test/flutter_test.dart';

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

DailyAssignment _seen(String conceptId, String dayKey) => DailyAssignment(
      dayKey: dayKey,
      conceptId: conceptId,
      pairKey: 'en_fr',
      assignedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('selectConceptForDay', () {
    test('same inputs always pick the same concept', () {
      final pool = _pool(8);
      String pick() => selectConceptForDay(
            pool: pool,
            history: const [],
            pairKey: 'en_fr',
            dayKey: '2026-07-17',
            userSeed: 'seed-A',
          ).id;
      expect(pick(), pick());
    });

    test('excludes concepts already seen in history', () {
      final pool = _pool(8);
      // Mark every concept but one as seen; the survivor must be picked.
      final history = [
        for (var i = 0; i < 7; i++) _seen('c0$i', '2026-07-${10 + i}'),
      ];
      final pick = selectConceptForDay(
        pool: pool,
        history: history,
        pairKey: 'en_fr',
        dayKey: '2026-07-17',
        userSeed: 'seed-A',
      );
      expect(pick.id, 'c07');
    });

    test('once the pool is exhausted, avoids the most recent picks', () {
      final pool = _pool(4);
      // All seen -> exhausted. Recent window (3) = last three days' concepts.
      final history = [
        _seen('c00', '2026-07-10'),
        _seen('c01', '2026-07-11'),
        _seen('c02', '2026-07-12'),
        _seen('c03', '2026-07-13'),
      ];
      final pick = selectConceptForDay(
        pool: pool,
        history: history,
        pairKey: 'en_fr',
        dayKey: '2026-07-17',
        userSeed: 'seed-A',
        avoidWindow: 3,
      );
      // c01/c02/c03 are the last three -> only c00 is allowed.
      expect(pick.id, 'c00');
    });

    test('throws when the pool is empty', () {
      expect(
        () => selectConceptForDay(
          pool: const [],
          history: const [],
          pairKey: 'en_fr',
          dayKey: '2026-07-17',
          userSeed: 'seed-A',
        ),
        throwsStateError,
      );
    });
  });

  group('stableHash', () {
    test('is deterministic and order-sensitive', () {
      expect(stableHash('abc'), stableHash('abc'));
      expect(stableHash('abc'), isNot(stableHash('acb')));
    });
  });
}
