import '../../core/logging/app_log.dart';
import '../../domain/models/corpus_config.dart';
import '../../domain/models/language_info.dart';
import '../../domain/models/language_pair.dart';
import '../services/corpus_asset_loader.dart';

/// Exposes corpus data as domain models. Currently provides the config;
/// concept selection is added when the daily card is built.
class CorpusRepository {
  CorpusRepository(this._loader);

  final CorpusAssetLoader _loader;
  CorpusConfig? _config;

  Future<CorpusConfig> loadConfig() async {
    if (_config != null) return _config!;
    final config = _parseConfig(
      (await _loader.loadRaw())['config'] as Map<String, dynamic>,
    );
    logger.d(
      '[corpus] config loaded: ${config.languages.length} languages, '
      '${config.activePairs.length} active pairs',
    );
    return _config = config;
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

    final activePairs = (config['active_pairs'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((pair) => LanguagePair(
              native: pair['native'] as String,
              target: pair['target'] as String,
            ))
        .toList();

    return CorpusConfig(languages: languages, activePairs: activePairs);
  }
}
