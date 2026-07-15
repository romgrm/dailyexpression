import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/domain/models/corpus_config.dart';
import 'package:daily_expression/domain/models/language_info.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/theme/app_spacing.dart';
import 'package:daily_expression/ui/core/widgets/widgets.dart';
import 'package:daily_expression/ui/features/onboarding/cubit/onboarding_cubit.dart';

final class LanguagePickScreen extends StatelessWidget {
  const LanguagePickScreen({super.key});

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
        return _LanguagePickView(config: config);
      },
    );
  }
}

final class _LanguagePickView extends StatelessWidget {
  const _LanguagePickView({required this.config});

  final CorpusConfig config;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uiLang = Localizations.localeOf(context).languageCode;
    final selectable = config.selectableNativeCodes;
    final orderedCodes = [
      ...selectable,
      ...config.languages.keys.where((code) => !selectable.contains(code)),
    ];
    final selected = context.watch<OnboardingCubit>().state.nativeCode;

    return AppScaffold(
      bottomAction: PrimaryButton(
        label: l10n.actionContinue,
        onPressed:
            selected == null ? null : () => context.go('/onboarding/target'),
      ),
      body: ListView(
        children: [
          const Sizer.xl(),
          Text(
            l10n.onboardingLanguageTitle,
            style: theme.textTheme.displaySmall,
          ),
          const Sizer.s(),
          Text(
            l10n.onboardingLanguageSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Sizer.xl(),
          for (final code in orderedCodes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _LanguageRow(
                info: config.languageByCode(code)!,
                label: config.languageByCode(code)!.displayName(uiLang),
                selectable: selectable.contains(code),
                selected: selected == code,
                onTap: selectable.contains(code)
                    ? () => context.read<OnboardingCubit>().selectNative(code)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

final class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.info,
    required this.label,
    required this.selectable,
    required this.selected,
    this.onTap,
  });

  final LanguageInfo info;
  final String label;
  final bool selectable;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Opacity(
      opacity: selectable ? 1 : 0.5,
      child: Material(
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
                Text(info.flag, style: const TextStyle(fontSize: 24)),
                const Sizer.m(),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (!selectable)
                  Pill(
                    label: l10n.onboardingComingSoon,
                    backgroundColor: scheme.surfaceContainerHighest,
                    foregroundColor: scheme.onSurfaceVariant,
                  )
                else if (selected)
                  Icon(Icons.check_circle, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
