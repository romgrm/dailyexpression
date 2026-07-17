import 'language_info.dart';
import 'language_pair.dart';

/// The corpus configuration: known languages and the active learning pairs.
/// The set of selectable native languages is derived from the active pairs, so
/// adding a pair in the corpus surfaces a new language with no code change.
class CorpusConfig {
  const CorpusConfig({
    required this.languages,
    required this.activePairs,
    required this.categories,
  });

  final Map<String, LanguageInfo> languages;
  final List<LanguagePair> activePairs;

  /// Theme code -> localized labels, e.g. `weather -> {en: Weather, fr: Météo}`.
  final Map<String, Map<String, String>> categories;

  /// Language codes a user can pick as their native language (those present as
  /// 'native' in an active pair). Other known languages are shown as waitlisted.
  List<String> get selectableNativeCodes =>
      activePairs.map((pair) => pair.native).toSet().toList();

  LanguageInfo? languageByCode(String code) => languages[code];

  /// The label for a category [code] in [uiLanguageCode], falling back to the
  /// English label and then to the raw code.
  String categoryLabel(String code, String uiLanguageCode) =>
      categories[code]?[uiLanguageCode] ?? categories[code]?['en'] ?? code;
}
