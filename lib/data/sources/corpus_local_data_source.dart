import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Local data source for the corpus: loads and decodes the bundled
/// `corpus.json` asset into a raw JSON map. This is the only place that touches
/// the asset bundle; a remote data source can later provide the same raw shape.
class CorpusLocalDataSource {
  CorpusLocalDataSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const _assetPath = 'assets/corpus/corpus.json';

  Future<Map<String, dynamic>> loadRaw() async {
    final jsonString = await _bundle.loadString(_assetPath);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}
