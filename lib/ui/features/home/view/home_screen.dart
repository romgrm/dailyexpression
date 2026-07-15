import 'package:flutter/material.dart';

import 'package:daily_expression/l10n/generated/app_localizations.dart';

/// Landing screen shown to onboarded users.
final class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context).appTitle,
          style: theme.textTheme.displaySmall,
        ),
      ),
    );
  }
}
