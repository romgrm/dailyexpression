import 'package:flutter/material.dart';

import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/theme/app_spacing.dart';
import 'package:daily_expression/ui/core/widgets/widgets.dart';

/// Splash / intro screen (ref: design/v1/splashscreen_v1.png).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Logo(size: 96),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Overline(l10n.appTagline, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xxxl),
              const PageDots(count: 3, index: 1),
            ],
          ),
        ),
      ),
    );
  }
}
