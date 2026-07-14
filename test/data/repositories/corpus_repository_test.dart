import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/data/services/corpus_asset_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses the config from the real corpus asset', () async {
    final repo = CorpusRepository(CorpusAssetLoader());
    final config = await repo.loadConfig();

    expect(config.languages.keys, containsAll(['en', 'fr', 'es', 'de']));
    expect(config.activePairs.length, 2);
    expect(config.selectableNativeCodes.toSet(), {'fr', 'es'});

    final fr = config.languageByCode('fr')!;
    expect(fr.nameNative, 'Français');
    expect(fr.displayName('es'), 'Francés');
    expect(fr.flag, isNotEmpty);
  });
}
