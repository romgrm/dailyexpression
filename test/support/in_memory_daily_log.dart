import 'package:daily_expression/domain/models/daily_assignment.dart';
import 'package:daily_expression/domain/repositories/daily_log_repository.dart';

/// In-memory [DailyLogRepository] for tests, mirroring the prefs implementation
/// semantics (idempotent save by (dayKey, pairKey); history sorted by day).
class InMemoryDailyLog implements DailyLogRepository {
  final List<DailyAssignment> entries = [];

  @override
  Future<DailyAssignment?> forDay(String dayKey, String pairKey) async {
    for (final entry in entries) {
      if (entry.dayKey == dayKey && entry.pairKey == pairKey) return entry;
    }
    return null;
  }

  @override
  Future<List<DailyAssignment>> history(String pairKey) async {
    return entries.where((e) => e.pairKey == pairKey).toList()
      ..sort((a, b) => a.dayKey.compareTo(b.dayKey));
  }

  @override
  Future<void> save(DailyAssignment assignment) async {
    entries
      ..removeWhere((e) =>
          e.dayKey == assignment.dayKey && e.pairKey == assignment.pairKey)
      ..add(assignment);
  }
}
