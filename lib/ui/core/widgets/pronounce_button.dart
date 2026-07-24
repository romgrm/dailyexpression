import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_expression/domain/speech/speech_synthesizer.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';

/// A speaker control that reads [text] aloud in [languageCode] via the
/// [SpeechSynthesizer] provided at the app root. Toggles between "play" and
/// "stop" while an utterance is in progress.
final class PronounceButton extends StatefulWidget {
  const PronounceButton({
    super.key,
    required this.text,
    required this.languageCode,
  });

  /// The phrase to speak (in the target language).
  final String text;

  /// The target language's two-letter code (e.g. 'en').
  final String languageCode;

  @override
  State<PronounceButton> createState() => _PronounceButtonState();
}

class _PronounceButtonState extends State<PronounceButton> {
  bool _speaking = false;

  Future<void> _toggle() async {
    final synthesizer = context.read<SpeechSynthesizer>();
    if (_speaking) {
      await synthesizer.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    try {
      await synthesizer.speak(widget.text, languageCode: widget.languageCode);
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return IconButton(
      onPressed: _toggle,
      color: scheme.primary,
      tooltip: l10n.dailyPronounceTooltip,
      icon: Icon(
        _speaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
      ),
    );
  }
}
