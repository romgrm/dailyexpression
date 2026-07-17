import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/data/sources/corpus_local_data_source.dart';
import 'package:daily_expression/domain/models/language_pair.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses the config from the real corpus asset', () async {
    final repo = CorpusRepository(CorpusLocalDataSource());
    final config = await repo.loadConfig();

    expect(config.languages.keys, containsAll(['en', 'fr', 'es', 'de']));
    expect(config.activePairs.length, 2);
    expect(config.selectableNativeCodes.toSet(), {'fr', 'es'});

    final fr = config.languageByCode('fr')!;
    expect(fr.nameNative, 'Français');
    expect(fr.displayName('es'), 'Francés');
    expect(fr.flag, isNotEmpty);

    expect(config.categoryLabel('weather', 'fr'), 'Météo');
  });

  test('availableConcepts returns all concepts for both active pairs', () async {
    final repo = CorpusRepository(CorpusLocalDataSource());

    final frEn = await repo.availableConcepts(
      const LanguagePair(native: 'fr', target: 'en'),
    );
    final esEn = await repo.availableConcepts(
      const LanguagePair(native: 'es', target: 'en'),
    );

    expect(frEn.length, 8);
    expect(esEn.length, 8);
    // Ids are unique and stable.
    expect(frEn.map((c) => c.id).toSet().length, 8);
  });

  test('conceptById resolves a known concept and preserves its note', () async {
    final repo = CorpusRepository(CorpusLocalDataSource());

    final rain = await repo.conceptById('rain_heavy');
    expect(rain, isNotNull);
    expect(rain!.category, 'weather');
    expect(rain.glosses['en_fr']?.isNonEquivalent, isFalse);
  });
}

