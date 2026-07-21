import 'dart:convert';

import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/data/sources/corpus_local_data_source.dart';
import 'package:daily_expression/domain/models/daily_expression.dart';
import 'package:daily_expression/domain/models/language_pair.dart';
import 'package:flutter/services.dart';

/// A curated, in-memory corpus shared by widget and golden tests. It mirrors
/// the shape of `assets/corpus/corpus_v2.json` but stays tiny so config and
/// concepts resolve synchronously inside the fake-async test zone (the real v2
/// asset is too large for `pumpAndSettle`).
///
/// Feed this whenever a new display case needs coverage: add a concept (a new
/// regional variant, a missing-native-equivalent, a non-equivalence note, ...)
/// and add a matching golden. The snapshot then shows the rendering without
/// waiting for the concept to surface on-device on its scheduled day.
const mockCorpusJson = '''
{
  "config": {
    "languages": {
      "en": {"name_native": "English", "display": {"fr": "Anglais", "en": "English"}, "flag": "GB"},
      "fr": {"name_native": "Français", "display": {"en": "French", "fr": "Français"}, "flag": "FR"}
    },
    "categories": {
      "weather": {"en": "Weather", "fr": "Météo"},
      "everyday": {"en": "Everyday", "fr": "Quotidien"}
    },
    "active_pairs": [
      {"native": "fr", "target": "en"},
      {"native": "en", "target": "fr"}
    ],
    "ui_strings": {
      "no_equivalent": {
        "fr": "Pas d'équivalent direct en français",
        "en": "No direct equivalent in English"
      }
    },
    "variants": {
      "fr-CA": {"en": "Quebec French", "fr": "Québécois"}
    }
  },
  "concepts": [
    {
      "id": "rain_heavy",
      "category": "weather",
      "level": "B1",
      "register": "neutral",
      "meaning": {"fr": "Pleuvoir très fort.", "en": "To rain very hard."},
      "forms": {
        "en": {"text": "It's raining cats and dogs.", "example": "We're staying in tonight, it's raining cats and dogs."},
        "fr": {"text": "Il pleut des cordes.", "example": "On reste à la maison, il pleut des cordes."}
      },
      "glosses": {
        "en_fr": {"literal": "Il pleut des chats et des chiens.", "example_translation": "On reste à la maison ce soir."},
        "fr_en": {"literal": "It's raining ropes.", "example_translation": "We're staying home tonight."}
      },
      "tags": []
    },
    {
      "id": "call_shotgun",
      "category": "everyday",
      "level": "A2",
      "register": "informal",
      "meaning": {"fr": "Revendiquer la place passager avant."},
      "forms": {
        "en": {"text": "to call shotgun", "example": "I call shotgun! I'm not sitting in the back."}
      },
      "glosses": {
        "en_fr": {"literal": "appeler le fusil de chasse", "example_translation": "Je prends la place avant ! Je ne m'assois pas derrière."}
      },
      "tags": []
    },
    {
      "id": "thumb_a_ride",
      "category": "everyday",
      "level": "B1",
      "register": "informal",
      "meaning": {"en": "To hitchhike.", "fr": "Faire de l'auto-stop."},
      "forms": {
        "fr": {"text": "faire du pouce", "example": "On a fait du pouce jusqu'à Montréal.", "variant": "fr-CA"},
        "en": {"text": "to thumb a ride", "example": "We thumbed a ride to Montreal."}
      },
      "glosses": {
        "fr_en": {"literal": "to do the thumb", "example_translation": "We hitchhiked to Montreal."},
        "en_fr": {"literal": "faire du pouce", "example_translation": "On a fait du stop jusqu'à Montréal."}
      },
      "tags": []
    },
    {
      "id": "spill_the_beans",
      "category": "everyday",
      "level": "B2",
      "register": "informal",
      "meaning": {"fr": "Révéler un secret."},
      "forms": {
        "en": {"text": "to spill the beans", "example": "Come on, spill the beans!"},
        "fr": {"text": "vendre la mèche", "example": "Allez, vends la mèche !"}
      },
      "glosses": {
        "en_fr": {
          "literal": "renverser les haricots",
          "example_translation": "Allez, dis-nous tout !",
          "note": "« Vendre la mèche » s'en rapproche, mais l'image diffère."
        }
      },
      "tags": []
    }
  ]
}
''';

/// An [AssetBundle] that serves [mockCorpusJson] for any key, so a
/// [CorpusRepository] can be built without touching the real asset bundle.
final class FakeCorpusAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = utf8.encode(mockCorpusJson);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}

/// A [CorpusRepository] backed by the in-memory [mockCorpusJson].
CorpusRepository buildMockCorpusRepository() =>
    CorpusRepository(CorpusLocalDataSource(bundle: FakeCorpusAssetBundle()));

/// The projection of a mock concept plus the native language name, mirroring
/// exactly what `DailyCubit` feeds into `DailyCard`.
typedef MockDaily = ({DailyExpression expression, String nativeLanguageName});

/// Projects [conceptId] from the mock corpus for [pair] and [uiLanguageCode],
/// following the same pipeline as `DailyCubit` (parse -> config -> projection)
/// so a golden reflects the real on-device rendering.
Future<MockDaily> loadMockDaily({
  required String conceptId,
  required LanguagePair pair,
  required String uiLanguageCode,
}) async {
  final corpus = buildMockCorpusRepository();
  final config = await corpus.loadConfig();
  final concept = await corpus.conceptById(conceptId);
  if (concept == null) {
    throw ArgumentError('Unknown mock concept: $conceptId');
  }
  final variantCode = concept.forms[pair.target]?.variant;
  final expression = DailyExpression.fromConcept(
    concept,
    pair,
    categoryLabel: config.categoryLabel(concept.category, uiLanguageCode),
    noEquivalentText: config.noEquivalentFor(pair.native),
    variantLabel: variantCode == null
        ? null
        : config.variantLabel(variantCode, uiLanguageCode),
  );
  final nativeName =
      config.languageByCode(pair.native)?.displayName(uiLanguageCode) ??
          pair.native;
  return (expression: expression, nativeLanguageName: nativeName);
}
