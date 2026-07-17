/// The word-for-word image of a target expression rendered in the native
/// language, plus a translation of its example. [note] flags a non-equivalence
/// (no direct idiom) and is null when there is nothing to flag.
class Gloss {
  const Gloss({
    required this.literal,
    required this.exampleTranslation,
    this.note,
  });

  final String literal;
  final String exampleTranslation;
  final String? note;

  bool get isNonEquivalent => note != null;
}
