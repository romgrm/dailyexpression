/// Port for reading text aloud with an on-device text-to-speech engine.
///
/// Implemented in the data layer (see `TtsSpeechService`). Kept in the
/// domain so the UI depends on this abstraction, not on a concrete plugin —
/// mirroring the `NotificationScheduler` port.
abstract class SpeechSynthesizer {
  /// Speaks [text] in the voice matching [languageCode] (a two-letter code such
  /// as 'en'). Resolves once the utterance finishes (or is stopped).
  Future<void> speak(String text, {required String languageCode});

  /// Stops any in-progress utterance immediately.
  Future<void> stop();
}
