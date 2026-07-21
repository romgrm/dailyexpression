import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/settings/settings_cubit.dart';
import 'package:daily_expression/ui/core/theme/app_spacing.dart';
import 'package:daily_expression/ui/core/widgets/widgets.dart';
import 'package:daily_expression/ui/features/onboarding/cubit/onboarding_cubit.dart';

final class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final onboarding = context.watch<OnboardingCubit>().state;
    final time = TimeOfDay(
      hour: onboarding.reminderHour,
      minute: onboarding.reminderMinute,
    );

    Future<void> complete() async {
      final native = onboarding.nativeCode;
      final target = onboarding.targetCode;
      if (native == null || target == null) return;
      await context.read<SettingsCubit>().completeOnboarding(
            nativeLanguage: native,
            targetLanguage: target,
            reminderHour: onboarding.reminderHour,
            reminderMinute: onboarding.reminderMinute,
          );
    }

    return AppScaffold(
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(label: l10n.actionEnableReminders, onPressed: complete),
          const Sizer.xs(),
          TextButton(onPressed: complete, child: Text(l10n.actionLater)),
        ],
      ),
      body: ListView(
        children: [
          const Sizer.xxxl(),
          const Center(child: _BellBadge()),
          const Sizer.xl(),
          Text(
            l10n.onboardingReminderTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const Sizer.s(),
          Text(
            l10n.onboardingReminderSubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Sizer.xl(),
          _TimeRow(
            label: l10n.onboardingReminderEveryDayAt,
            time: time,
            onTap: () async {
              final picked =
                  await showTimePicker(context: context, initialTime: time);
              if (picked != null && context.mounted) {
                context
                    .read<OnboardingCubit>()
                    .setReminderTime(picked.hour, picked.minute);
              }
            },
          ),
        ],
      ),
    );
  }
}

final class _BellBadge extends StatelessWidget {
  const _BellBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Icon(Icons.notifications_none, size: 48, color: scheme.primary),
    );
  }
}

final class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final formatted = MaterialLocalizations.of(context).formatTimeOfDay(time);

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(color: scheme.outlineVariant),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.schedule, color: scheme.primary),
              const Sizer.m(),
              Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
              Text(
                formatted,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
