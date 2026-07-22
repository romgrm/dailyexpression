import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/domain/repositories/streak_repository.dart';
import 'package:daily_expression/domain/time/clock.dart';
import 'package:daily_expression/domain/use_cases/get_daily_expression.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/settings/settings_cubit.dart';
import 'package:daily_expression/ui/core/theme/app_colors.dart';
import 'package:daily_expression/ui/core/theme/app_spacing.dart';
import 'package:daily_expression/ui/core/widgets/widgets.dart';
import '../cubit/daily_cubit.dart';
import '../cubit/daily_state.dart';
import 'widgets/daily_card.dart';

/// The daily expression screen. Owns its [DailyCubit] view-model, built from the
/// shared repositories provided at the app root, and renders its states.
final class DailyView extends StatelessWidget {
  const DailyView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final uiLanguageCode = Localizations.localeOf(context).languageCode;
    final nativeLanguageCode = settings.nativeLanguage ?? 'fr';
    final targetLanguageCode = settings.targetLanguage ?? 'en';
    return BlocProvider(
      key: ValueKey('$nativeLanguageCode|$targetLanguageCode|$uiLanguageCode'),
      create: (context) => DailyCubit(
        corpus: context.read<CorpusRepository>(),
        getDailyExpression: context.read<GetDailyExpression>(),
        streakRepository: context.read<StreakRepository>(),
        clock: context.read<Clock>(),
        uiLanguageCode: uiLanguageCode,
        nativeLanguageCode: nativeLanguageCode,
        targetLanguageCode: targetLanguageCode,
      ),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<DailyCubit, DailyState>(
            builder: (context, state) => switch (state) {
              DailyLoading() =>
                const Center(child: CircularProgressIndicator()),
              DailyError() => const _DailyErrorView(),
              DailyLoaded() => _DailyContent(state: state),
            },
          ),
        ),
      ),
    );
  }
}

final class _DailyContent extends StatelessWidget {
  const _DailyContent({required this.state});

  final DailyLoaded state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final formattedDate =
        DateFormat('EEEE d MMMM', locale).format(state.date);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(streakCount: state.streakCount),
          const Sizer.l(),
          Overline('${l10n.dailyToday} · $formattedDate'),
          const Sizer.m(),
          DailyCard(
            expression: state.expression,
            nativeLanguageName: state.nativeLanguageName,
          ),
        ],
      ),
    );
  }
}

final class _TopBar extends StatelessWidget {
  const _TopBar({required this.streakCount});

  final int streakCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        const Logo(size: AppSpacing.xxxl),
        const Sizer.s(),
        Text(l10n.appTitle, style: theme.textTheme.titleLarge),
        const Spacer(),
        _StreakChip(count: streakCount),
        const Sizer.xs(),
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
          tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
        ),
      ],
    );
  }
}

/// The consecutive-day streak as a flame chip, using the supplementary flame
/// tokens (like the gold CEFR badge, these live outside the Material scheme).
final class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      message: l10n.dailyStreakTooltip(count),
      child: Pill(
        icon: Icons.local_fire_department,
        label: '$count',
        backgroundColor:
            isDark ? AppColors.flameBackgroundDark : AppColors.flameBackground,
        foregroundColor: isDark ? AppColors.flameDark : AppColors.flame,
      ),
    );
  }
}

final class _DailyErrorView extends StatelessWidget {
  const _DailyErrorView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.dailyError, textAlign: TextAlign.center),
            const Sizer.m(),
            TextButton(
              onPressed: () => context.read<DailyCubit>().load(),
              child: Text(l10n.dailyRetry),
            ),
          ],
        ),
      ),
    );
  }
}
