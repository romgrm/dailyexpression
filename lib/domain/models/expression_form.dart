/// A single expression rendered in one language: the idiom [text] and an
/// [example] sentence using it.
class ExpressionForm {
  const ExpressionForm({required this.text, required this.example});

  final String text;
  final String example;
}
