/// Maps a corpus two-letter language code (e.g. 'en') to the BCP-47 locale tag
/// expected by the text-to-speech engines (e.g. 'en-US').
///
/// Falls back to a reasonable default region per known language, and finally to
/// the code itself so an unmapped language still attempts synthesis rather than
/// failing outright.
String ttsLocaleFor(String languageCode) {
  final code = languageCode.trim().toLowerCase();
  return switch (code) {
    'en' => 'en-US',
    'fr' => 'fr-FR',
    'es' => 'es-ES',
    'it' => 'it-IT',
    'de' => 'de-DE',
    'pt' => 'pt-PT',
    _ => code,
  };
}
