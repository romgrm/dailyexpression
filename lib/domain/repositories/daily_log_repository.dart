import '../models/daily_assignment.dart';

/// Persists the per-user daily assignment log. Local-only for the MVP
/// (shared_preferences); a future Supabase-backed implementation swaps in
/// behind this same interface without touching the use case or UI.
abstract interface class DailyLogRepository {
  /// The assignment recorded for [dayKey] and [pairKey], or null if none.
  Future<DailyAssignment?> forDay(String dayKey, String pairKey);

  /// All assignments for [pairKey], ordered by day ascending.
  Future<List<DailyAssignment>> history(String pairKey);

  /// Records [assignment], replacing any existing entry for the same
  /// (dayKey, pairKey) — idempotent, so re-saving a day is a no-op.
  Future<void> save(DailyAssignment assignment);
}
