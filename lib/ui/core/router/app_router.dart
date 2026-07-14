import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Builds the app router. For now a single placeholder home route; the
/// onboarding redirect gate and feature routes are added in later milestones.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PlaceholderHome(),
      ),
    ],
  );
}

/// Temporary themed home shown until the daily card lands (M3).
class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appTitle, style: theme.textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              l10n.appTagline.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
