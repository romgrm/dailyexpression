import 'package:flutter_tts/flutter_tts.dart';

import 'package:daily_expression/domain/speech/speech_synthesizer.dart';
import 'package:daily_expression/domain/speech/tts_locale.dart';

/// [SpeechSynthesizer] backed by the platform text-to-speech engine
/// (iOS AVSpeechSynthesizer / Android TextToSpeech) via `flutter_tts`.
///
/// Fully on-device: no network, no permission. Thin adapter — the only logic is
/// the language-code → locale mapping, unit-tested in `ttsLocaleFor`.
class TtsSpeechService implements SpeechSynthesizer {
  TtsSpeechService([FlutterTts? tts]) : _tts = tts ?? FlutterTts() {
    // Make `speak` await the utterance so callers can reflect the speaking
    // state and re-enable the control when playback ends.
    _tts.awaitSpeakCompletion(true);
  }

  final FlutterTts _tts;

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.setLanguage(ttsLocaleFor(languageCode));
    await _tts.speak(text);
  }

  @override
  Future<void> stop() => _tts.stop();
}
