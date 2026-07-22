import '../models/concept.dart';
import '../models/daily_assignment.dart';

/// Deterministic, side-effect-free pick of the concept for one `(pair, day)`.
///
/// Shared by [GetDailyExpression] (today, which then persists the pick) and the
/// reminder/widget preview (future days, no persistence) so a scheduled
/// notification always teases the same idiom the card will reveal. Determinism
/// comes from the per-user [userSeed] + [pairKey] + [dayKey]; identical inputs
/// reproduce the same concept everywhere.
Concept selectConceptForDay({
  required List<Concept> pool,
  required List<DailyAssignment> history,
  required String pairKey,
  required String dayKey,
  required String userSeed,
  int avoidWindow = 3,
}) {
  if (pool.isEmpty) {
    throw StateError('No available concepts for $pairKey');
  }

  final seen = history.map((entry) => entry.conceptId).toSet();
  var candidates = pool.where((c) => !seen.contains(c.id)).toList();
  if (candidates.isEmpty) {
    final recent = _recentIds(history, avoidWindow);
    candidates = pool.where((c) => !recent.contains(c.id)).toList();
    if (candidates.isEmpty) candidates = List.of(pool);
  }

  candidates.sort((a, b) {
    final ha = stableHash('$userSeed|$pairKey|$dayKey|${a.id}');
    final hb = stableHash('$userSeed|$pairKey|$dayKey|${b.id}');
    return ha != hb ? ha.compareTo(hb) : a.id.compareTo(b.id);
  });

  return candidates.first;
}

/// The ids of the last [k] entries (most recent first), used to avoid immediate
/// repeats after the pool is exhausted.
Set<String> _recentIds(List<DailyAssignment> history, int k) {
  if (k <= 0) return const {};
  return history.reversed.take(k).map((entry) => entry.conceptId).toSet();
}

/// Deterministic FNV-1a 32-bit hash — stable across launches and platforms,
/// unlike `String.hashCode` which is not guaranteed stable across runs.
int stableHash(String input) {
  var hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}
