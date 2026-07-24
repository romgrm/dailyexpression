import 'package:daily_expression/domain/speech/tts_locale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ttsLocaleFor', () {
    test('maps known languages to a BCP-47 locale with a default region', () {
      expect(ttsLocaleFor('en'), 'en-US');
      expect(ttsLocaleFor('fr'), 'fr-FR');
      expect(ttsLocaleFor('es'), 'es-ES');
      expect(ttsLocaleFor('it'), 'it-IT');
      expect(ttsLocaleFor('de'), 'de-DE');
      expect(ttsLocaleFor('pt'), 'pt-PT');
    });

    test('normalizes case and surrounding whitespace', () {
      expect(ttsLocaleFor('EN'), 'en-US');
      expect(ttsLocaleFor('  fr  '), 'fr-FR');
    });

    test('falls back to the normalized code for unmapped languages', () {
      expect(ttsLocaleFor('nl'), 'nl');
      expect(ttsLocaleFor('JA'), 'ja');
    });
  });
}
