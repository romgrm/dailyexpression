/// A record of which concept was shown on a given local day, for a given
/// language pair. The natural key is (dayKey, pairKey); it maps 1:1 to a future
/// Supabase row keyed (user_id, pair_key, day_key). [schemaVersion] and
/// [assignedAt] are carried from the first version as migration/merge insurance.
class DailyAssignment {
  const DailyAssignment({
    required this.dayKey,
    required this.conceptId,
    required this.pairKey,
    required this.assignedAt,
    this.schemaVersion = 1,
  });

  /// Local calendar day, formatted `yyyy-MM-dd`.
  final String dayKey;
  final String conceptId;

  /// The language couple, e.g. 'en_fr'.
  final String pairKey;
  final DateTime assignedAt;
  final int schemaVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyAssignment &&
          other.dayKey == dayKey &&
          other.pairKey == pairKey &&
          other.conceptId == conceptId &&
          other.schemaVersion == schemaVersion;

  @override
  int get hashCode => Object.hash(dayKey, pairKey, conceptId, schemaVersion);
}
