import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/domain/models/corpus_config.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/theme/app_spacing.dart';
import 'package:daily_expression/ui/core/widgets/widgets.dart';

final class TargetConfirmScreen extends StatelessWidget {
  const TargetConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uiLang = Localizations.localeOf(context).languageCode;

    return FutureBuilder<CorpusConfig>(
      future: context.read<CorpusRepository>().loadConfig(),
      builder: (context, snapshot) {
        final config = snapshot.data;
        if (config == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final targetInfo =
            config.languageByCode(config.activePairs.first.target)!;

        return AppScaffold(
          bottomAction: PrimaryButton(
            label: l10n.actionStart,
            trailingIcon: Icons.arrow_forward,
            onPressed: () => context.go('/onboarding/reminders'),
          ),
          body: ListView(
            children: [
              const Sizer.xl(),
              Text(
                l10n.onboardingTargetTitle,
                style: theme.textTheme.displaySmall,
              ),
              const Sizer.s(),
              Text(
                l10n.onboardingTargetSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Sizer.xl(),
              _LockedLanguageCard(
                flag: targetInfo.flag,
                label: targetInfo.displayName(uiLang),
              ),
              const Sizer.m(),
              SectionCard(
                child: Text(
                  l10n.onboardingTargetDescription,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final class _LockedLanguageCard extends StatelessWidget {
  const _LockedLanguageCard({required this.flag, required this.label});

  final String flag;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: scheme.primary),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const Sizer.m(),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
