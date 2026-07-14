import 'language_info.dart';
import 'language_pair.dart';

/// The corpus configuration: known languages and the active learning pairs.
/// The set of selectable native languages is derived from the active pairs, so
/// adding a pair in the corpus surfaces a new language with no code change.
class CorpusConfig {
  const CorpusConfig({required this.languages, required this.activePairs});

  final Map<String, LanguageInfo> languages;
  final List<LanguagePair> activePairs;

  /// Language codes a user can pick as their native language (those present as
  /// 'native' in an active pair). Other known languages are shown as waitlisted.
  List<String> get selectableNativeCodes =>
      activePairs.map((pair) => pair.native).toSet().toList();

  LanguageInfo? languageByCode(String code) => languages[code];
}
