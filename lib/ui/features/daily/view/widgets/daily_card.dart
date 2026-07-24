import 'package:flutter/material.dart';

import 'package:daily_expression/domain/models/daily_expression.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/theme/app_colors.dart';
import 'package:daily_expression/ui/core/theme/app_spacing.dart';
import 'package:daily_expression/ui/core/widgets/widgets.dart';

/// The hero card: the idiom, its literal image, the native equivalent, and an
/// in-context example — composed in the corpus `daily_card_render` order.
final class DailyCard extends StatelessWidget {
  const DailyCard({
    super.key,
    required this.expression,
    required this.nativeLanguageName,
    required this.targetLanguageCode,
  });

  final DailyExpression expression;
  final String nativeLanguageName;
  final String targetLanguageCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Pill(
                  label: expression.categoryLabel.toUpperCase(),
                  icon: _categoryIcon(expression.category),
                ),
                if (expression.variantLabel != null)
                  Pill(
                    label: expression.variantLabel!.toUpperCase(),
                    icon: Icons.place_outlined,
                    backgroundColor: scheme.surfaceContainerHighest,
                    foregroundColor: scheme.onSurfaceVariant,
                  ),
                _CefrBadge(level: expression.level.label),
              ],
            ),
          ),
          Divider(height: AppSpacing.hairline, color: scheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '"${expression.idiom}"',
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                    PronounceButton(
                      text: expression.idiom,
                      languageCode: targetLanguageCode,
                    ),
                  ],
                ),
                const Sizer.m(),
                Text(
                  l10n.dailyLiteral(expression.literalImage),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Sizer.l(),
                Divider(height: AppSpacing.hairline, color: scheme.outlineVariant),
                const Sizer.l(),
                _EquivalentBlock(
                  languageName: nativeLanguageName,
                  equivalent: expression.nativeEquivalentOrPlaceholder,
                  isPlaceholder: !expression.hasNativeEquivalent,
                ),
                if (expression.isNonEquivalent) ...[
                  const Sizer.s(),
                  _NonEquivalenceCallout(note: expression.nonEquivalenceNote!),
                ],
                const Sizer.l(),
                SizedBox(
                  width: double.infinity,
                  child: _ContextBlock(
                    example: expression.example,
                    translation: expression.exampleTranslation,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _categoryIcon(String category) => switch (category) {
      'weather' => Icons.cloud_outlined,
      'money' => Icons.payments_outlined,
      'time' => Icons.schedule_outlined,
      'suspicion' => Icons.search_outlined,
      'emotions' => Icons.favorite_outline,
      'priorities' => Icons.flag_outlined,
      'everyday' => Icons.wb_sunny_outlined,
      _ => Icons.label_outline,
    };

/// The gold CEFR level chip (e.g. "B1").
final class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.goldBadgeBackgroundDark
        : AppColors.goldBadgeBackground;
    final foreground =
        isDark ? AppColors.goldBadgeTextDark : AppColors.goldBadgeText;

    return Container(
      width: AppSpacing.xxxl,
      height: AppSpacing.xxxl,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        level,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// The teal-tinted "equivalent in <language>" block with a leading accent bar.
final class _EquivalentBlock extends StatelessWidget {
  const _EquivalentBlock({
    required this.languageName,
    required this.equivalent,
    this.isPlaceholder = false,
  });

  final String languageName;
  final String equivalent;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: AppSpacing.xxs, color: scheme.primary),
            Expanded(
              child: Container(
                color: scheme.secondaryContainer,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Overline(l10n.dailyEquivalentIn(languageName)),
                    const Sizer.xs(),
                    Text(
                      equivalent,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontStyle:
                            isPlaceholder ? FontStyle.italic : FontStyle.normal,
                        color: isPlaceholder ? scheme.onSurfaceVariant : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The muted "in context" block: the example and its native translation.
final class _ContextBlock extends StatelessWidget {
  const _ContextBlock({required this.example, required this.translation});

  final String example;
  final String translation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SectionCard(
      color: scheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Overline(l10n.dailyInContext),
          const Sizer.s(),
          Text(
            '"$example"',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Sizer.xs(),
          Text(
            l10n.dailyExampleTranslation(translation),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// A discreet callout shown only when the couple has no direct idiom.
final class _NonEquivalenceCallout extends StatelessWidget {
  const _NonEquivalenceCallout({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: AppSpacing.md, color: scheme.onSurfaceVariant),
        const Sizer.xs(),
        Expanded(
          child: Text(
            note,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
