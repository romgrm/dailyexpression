/// Descriptor for a language from the corpus config: its own name, its display
/// name in each UI language, and its flag emoji.
class LanguageInfo {
  const LanguageInfo({
    required this.code,
    required this.nameNative,
    required this.displayNames,
    required this.flag,
  });

  final String code;
  final String nameNative;
  final Map<String, String> displayNames;
  final String flag;

  /// The name to show, localized to [uiLanguageCode], falling back to the
  /// language's own native name.
  String displayName(String uiLanguageCode) =>
      displayNames[uiLanguageCode] ?? nameNative;
}
