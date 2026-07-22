import '../models/streak_state.dart';

/// Persists the user's open streak. Local-only for the MVP
/// (shared_preferences); a future backend-backed implementation swaps in behind
/// this same interface without touching the calculator or UI.
abstract interface class StreakRepository {
  /// The persisted streak, or an empty [StreakState] (count 0, no last day) if
  /// none has been recorded yet.
  Future<StreakState> read();

  /// Persists [state], replacing the previous value.
  Future<void> save(StreakState state);
}
