import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/data/sources/corpus_local_data_source.dart';
import 'package:daily_expression/domain/models/language_pair.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repo = CorpusRepository(CorpusLocalDataSource());

  test('parses the v2 config from the real corpus asset', () async {
    final config = await repo.loadConfig();

    expect(config.languages.keys, containsAll(['en', 'fr', 'es', 'de']));
    expect(config.activePairs.length, 2);
    expect(config.selectableNativeCodes.toSet(), {'fr', 'en'});
    expect(config.targetsFor('fr'), ['en']);
    expect(config.targetsFor('en'), ['fr']);

    expect(config.categoryLabel('weather', 'fr'), 'Météo');
    expect(config.noEquivalentFor('fr'), isNotEmpty);
    expect(config.variantLabel('fr-CA', 'fr'), 'Québécois');
  });

  test('availableConcepts counts per active pair (v2)', () async {
    final frEn = await repo.availableConcepts(
      const LanguagePair(native: 'fr', target: 'en'),
    );
    final enFr = await repo.availableConcepts(
      const LanguagePair(native: 'en', target: 'fr'),
    );

    expect(frEn.length, 111);
    expect(enFr.length, 112);
    expect(frEn.map((c) => c.id).toSet().length, frEn.length);
  });

  test('a concept without a native form is still available (v2 rule)',
      () async {
    final shotgun = await repo.conceptById('call_shotgun');
    expect(shotgun, isNotNull);
    expect(shotgun!.forms.containsKey('en'), isTrue);
    expect(shotgun.forms.containsKey('fr'), isFalse);
    // Available for fr->en (learning English from French) despite no FR form.
    expect(
      shotgun.isAvailableFor(const LanguagePair(native: 'fr', target: 'en')),
      isTrue,
    );
    // Not available for en->fr: it has no French (target) form.
    expect(
      shotgun.isAvailableFor(const LanguagePair(native: 'en', target: 'fr')),
      isFalse,
    );
  });

  test('regional variant is parsed on the form', () async {
    final thumb = await repo.conceptById('thumb_a_ride');
    expect(thumb, isNotNull);
    expect(thumb!.forms['fr']?.variant, 'fr-CA');
  });
}
