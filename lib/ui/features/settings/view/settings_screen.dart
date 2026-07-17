import 'package:flutter/material.dart';

import 'package:daily_expression/l10n/generated/app_localizations.dart';

/// Preferences screen. Fleshed out with the theme switcher and language/reminder
/// controls in a later slice; for now it hosts the back navigation target for
/// the daily card's gear button.
final class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: const SizedBox.shrink(),
    );
  }
}
