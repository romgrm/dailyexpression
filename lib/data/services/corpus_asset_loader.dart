import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Loads and decodes the bundled corpus asset into a raw JSON map.
class CorpusAssetLoader {
  CorpusAssetLoader({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const _assetPath = 'assets/corpus/corpus.json';

  Future<Map<String, dynamic>> loadRaw() async {
    final jsonString = await _bundle.loadString(_assetPath);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}
