/// The user's consecutive-day open streak. [lastOpenedDay] is the local
/// calendar day (date-only) of the most recent app open that counted toward the
/// streak. [schemaVersion] is migration/merge insurance for a future backend
/// sync, mirroring [DailyAssignment].
class StreakState {
  const StreakState({
    this.count = 0,
    this.lastOpenedDay,
    this.schemaVersion = 1,
  });

  final int count;

  /// Local calendar day (date-only) of the last counted open, or null if the
  /// user has never opened the app.
  final DateTime? lastOpenedDay;
  final int schemaVersion;

  StreakState copyWith({
    int? count,
    DateTime? lastOpenedDay,
    int? schemaVersion,
  }) {
    return StreakState(
      count: count ?? this.count,
      lastOpenedDay: lastOpenedDay ?? this.lastOpenedDay,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakState &&
          other.count == count &&
          other.lastOpenedDay == lastOpenedDay &&
          other.schemaVersion == schemaVersion;

  @override
  int get hashCode => Object.hash(count, lastOpenedDay, schemaVersion);
}
