/// A single expression rendered in one language: the idiom [text] and an
/// [example] sentence using it. [variant] is an optional regional code.
class ExpressionForm {
  const ExpressionForm({
    required this.text,
    required this.example,
    this.variant,
  });

  final String text;
  final String example;

  /// Optional regional variant code (e.g. 'fr-CA'); null = pan-regional.
  final String? variant;
}
