import '../models/concept.dart';
import '../models/daily_assignment.dart';
import '../models/language_pair.dart';
import '../repositories/daily_log_repository.dart';
import '../time/clock.dart';

/// Resolves the expression for today, per language pair, and records it.
///
/// Resolve-or-assign: if the day already has a logged concept it is returned
/// unchanged (history stays frozen even as the corpus grows). Otherwise a new
/// concept is picked deterministically from the pool minus what has already
/// been seen, then persisted. Determinism comes from a per-user [userSeed] plus
/// the day key, so the same user reproduces the same stream, and tests are
/// reproducible by injecting the clock, seed, and log.
class GetDailyExpression {
  const GetDailyExpression({
    required DailyLogRepository log,
    required Clock clock,
    required String userSeed,
  })  : _log = log,
        _clock = clock,
        _userSeed = userSeed;

  final DailyLogRepository _log;
  final Clock _clock;
  final String _userSeed;

  /// How many of the most recently seen concepts to avoid when the pool has
  /// been exhausted and we must allow repeats.
  static const _avoidWindow = 3;

  Future<Concept> call({
    required LanguagePair pair,
    required List<Concept> pool,
  }) async {
    if (pool.isEmpty) {
      throw StateError('No available concepts for ${pair.glossKey}');
    }

    final dayKey = dayKeyOf(_clock.now());
    final pairKey = pair.glossKey;

    final existing = await _log.forDay(dayKey, pairKey);
    if (existing != null) {
      final match = _byId(pool, existing.conceptId);
      if (match != null) return match;
    }

    final history = await _log.history(pairKey);
    final seen = history.map((entry) => entry.conceptId).toSet();

    var candidates = pool.where((c) => !seen.contains(c.id)).toList();
    if (candidates.isEmpty) {
      final recent = _recentIds(history, _avoidWindow);
      candidates = pool.where((c) => !recent.contains(c.id)).toList();
      if (candidates.isEmpty) candidates = List.of(pool);
    }

    candidates.sort((a, b) {
      final ha = _stableHash('$_userSeed|$pairKey|$dayKey|${a.id}');
      final hb = _stableHash('$_userSeed|$pairKey|$dayKey|${b.id}');
      return ha != hb ? ha.compareTo(hb) : a.id.compareTo(b.id);
    });

    final pick = candidates.first;
    await _log.save(DailyAssignment(
      dayKey: dayKey,
      conceptId: pick.id,
      pairKey: pairKey,
      assignedAt: _clock.now(),
    ));
    return pick;
  }

  static Concept? _byId(List<Concept> pool, String id) {
    for (final concept in pool) {
      if (concept.id == id) return concept;
    }
    return null;
  }

  /// The ids of the last [k] entries (most recent first), used to avoid
  /// immediate repeats after the pool is exhausted.
  static Set<String> _recentIds(List<DailyAssignment> history, int k) {
    if (k <= 0) return const {};
    return history.reversed.take(k).map((entry) => entry.conceptId).toSet();
  }

  /// Deterministic FNV-1a 32-bit hash — stable across launches and platforms,
  /// unlike `String.hashCode` which is not guaranteed stable across runs.
  static int _stableHash(String input) {
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }
}
