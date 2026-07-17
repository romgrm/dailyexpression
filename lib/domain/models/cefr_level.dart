/// Approximate CEFR level of the target expression (indicative).
enum CefrLevel {
  a1,
  a2,
  b1,
  b2,
  c1,
  c2;

  /// Uppercase display code, e.g. 'B1'.
  String get label => name.toUpperCase();

  static CefrLevel fromCode(String code) => values.firstWhere(
        (level) => level.name == code.toLowerCase(),
        orElse: () => throw ArgumentError('Unknown CEFR level: $code'),
      );
}
