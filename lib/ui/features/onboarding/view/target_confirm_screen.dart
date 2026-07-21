import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/domain/models/corpus_config.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/theme/app_spacing.dart';
import 'package:daily_expression/ui/core/widgets/widgets.dart';
import 'package:daily_expression/ui/features/onboarding/cubit/onboarding_cubit.dart';

final class TargetConfirmScreen extends StatelessWidget {
  const TargetConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CorpusConfig>(
      future: context.read<CorpusRepository>().loadConfig(),
      builder: (context, snapshot) {
        final config = snapshot.data;
        if (config == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _TargetView(config: config);
      },
    );
  }
}

final class _TargetView extends StatelessWidget {
  const _TargetView({required this.config});

  final CorpusConfig config;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uiLang = Localizations.localeOf(context).languageCode;
    final onboarding = context.watch<OnboardingCubit>().state;
    final native = onboarding.nativeCode;
    final targets = native == null ? const <String>[] : config.targetsFor(native);
    // With a single available target the choice is pre-selected (a confirm step).
    final selected =
        onboarding.targetCode ?? (targets.length == 1 ? targets.first : null);

    return AppScaffold(
      bottomAction: PrimaryButton(
        label: l10n.actionStart,
        trailingIcon: Icons.arrow_forward,
        onPressed: selected == null
            ? null
            : () {
                context.read<OnboardingCubit>().selectTarget(selected);
                context.go('/onboarding/reminders');
              },
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
          for (final code in targets)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _TargetRow(
                flag: config.languageByCode(code)!.flag,
                label: config.languageByCode(code)!.displayName(uiLang),
                selected: selected == code,
                onTap: () =>
                    context.read<OnboardingCubit>().selectTarget(code),
              ),
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
  }
}

final class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.secondaryContainer : scheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const Sizer.m(),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
