import '../../core/logging/app_log.dart';
import '../../domain/models/cefr_level.dart';
import '../../domain/models/concept.dart';
import '../../domain/models/corpus_config.dart';
import '../../domain/models/expression_form.dart';
import '../../domain/models/gloss.dart';
import '../../domain/models/language_info.dart';
import '../../domain/models/language_pair.dart';
import '../../domain/models/register.dart';
import '../sources/corpus_local_data_source.dart';

/// Exposes corpus data as domain models: the config, and the concepts filtered
/// and ordered for a language pair. Parses the bundled asset once and caches it.
class CorpusRepository {
  CorpusRepository(this._source);

  final CorpusLocalDataSource _source;
  Future<Map<String, dynamic>>? _rawFuture;
  Future<CorpusConfig>? _configFuture;
  Future<List<Concept>>? _conceptsFuture;

  Future<Map<String, dynamic>> _rawData() => _rawFuture ??= _source.loadRaw();

  Future<CorpusConfig> loadConfig() =>
      _configFuture ??= _parseConfigFromAsset();

  Future<CorpusConfig> _parseConfigFromAsset() async {
    final config = _parseConfig(
      (await _rawData())['config'] as Map<String, dynamic>,
    );
    logger.d(
      '[corpus] config loaded: ${config.languages.length} languages, '
      '${config.activePairs.length} active pairs',
    );
    return config;
  }

  /// Concepts usable for [pair], in corpus order (stable, drives selection).
  Future<List<Concept>> availableConcepts(LanguagePair pair) async {
    final concepts = await _loadConcepts();
    return concepts.where((concept) => concept.isAvailableFor(pair)).toList();
  }

  /// The concept with [id], or null if it is not in the corpus.
  Future<Concept?> conceptById(String id) async {
    for (final concept in await _loadConcepts()) {
      if (concept.id == id) return concept;
    }
    return null;
  }

  /// Localized label for a category [code] in [uiLanguageCode].
  Future<String> categoryLabel(String code, String uiLanguageCode) async {
    final config = await loadConfig();
    return config.categoryLabel(code, uiLanguageCode);
  }

  Future<List<Concept>> _loadConcepts() =>
      _conceptsFuture ??= _parseConceptsFromAsset();

  Future<List<Concept>> _parseConceptsFromAsset() async {
    final concepts = (await _rawData())['concepts'] as List<dynamic>;
    final parsed =
        concepts.cast<Map<String, dynamic>>().map(_parseConcept).toList();
    logger.d('[corpus] parsed ${parsed.length} concepts');
    return parsed;
  }

  static CorpusConfig _parseConfig(Map<String, dynamic> config) {
    final languages = <String, LanguageInfo>{};
    final languagesJson = config['languages'] as Map<String, dynamic>;
    for (final entry in languagesJson.entries) {
      final data = entry.value as Map<String, dynamic>;
      final display = (data['display'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, value as String));
      languages[entry.key] = LanguageInfo(
        code: entry.key,
        nameNative: data['name_native'] as String,
        displayNames: display,
        flag: data['flag'] as String,
      );
    }

    final categories = <String, Map<String, String>>{};
    final categoriesJson =
        config['categories'] as Map<String, dynamic>? ?? const {};
    for (final entry in categoriesJson.entries) {
      categories[entry.key] = (entry.value as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value as String));
    }

    final activePairs = (config['active_pairs'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((pair) => LanguagePair(
              native: pair['native'] as String,
              target: pair['target'] as String,
            ))
        .toList();

    final noEquivalent = <String, String>{};
    final noEquivJson = (config['ui_strings'] as Map<String, dynamic>?)?[
        'no_equivalent'] as Map<String, dynamic>?;
    if (noEquivJson != null) {
      for (final entry in noEquivJson.entries) {
        noEquivalent[entry.key] = entry.value as String;
      }
    }

    final variants = <String, Map<String, String>>{};
    final variantsJson = config['variants'] as Map<String, dynamic>? ?? const {};
    for (final entry in variantsJson.entries) {
      variants[entry.key] = (entry.value as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value as String));
    }

    return CorpusConfig(
      languages: languages,
      activePairs: activePairs,
      categories: categories,
      noEquivalent: noEquivalent,
      variants: variants,
    );
  }

  static Concept _parseConcept(Map<String, dynamic> json) {
    final meaning = (json['meaning'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as String));

    final forms = (json['forms'] as Map<String, dynamic>).map((key, value) {
      final form = value as Map<String, dynamic>;
      return MapEntry(
        key,
        ExpressionForm(
          text: form['text'] as String,
          example: form['example'] as String,
          variant: form['variant'] as String?,
        ),
      );
    });

    final glosses = (json['glosses'] as Map<String, dynamic>).map((key, value) {
      final gloss = value as Map<String, dynamic>;
      return MapEntry(
        key,
        Gloss(
          literal: gloss['literal'] as String,
          exampleTranslation: gloss['example_translation'] as String,
          note: gloss['note'] as String?,
        ),
      );
    });

    return Concept(
      id: json['id'] as String,
      category: json['category'] as String,
      level: CefrLevel.fromCode(json['level'] as String),
      register: Register.fromCode(json['register'] as String),
      meaning: meaning,
      forms: forms,
      glosses: glosses,
      tags: (json['tags'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }
}
