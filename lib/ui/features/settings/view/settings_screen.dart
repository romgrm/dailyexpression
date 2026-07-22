import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/domain/models/app_settings.dart';
import 'package:daily_expression/domain/models/app_theme_mode.dart';
import 'package:daily_expression/domain/models/corpus_config.dart';
import 'package:daily_expression/domain/notifications/notification_permission.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/notifications/reminder_coordinator.dart';
import 'package:daily_expression/ui/core/settings/settings_cubit.dart';
import 'package:daily_expression/ui/core/theme/app_spacing.dart';
import 'package:daily_expression/ui/core/widgets/widgets.dart';

/// App version shown in the About section. Kept in sync with pubspec.
const String _appVersion = '1.0.0';

/// Preferences screen: source language, daily reminder time, theme switcher,
/// plus an About section. All changes persist through [SettingsCubit].
final class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: FutureBuilder<CorpusConfig>(
        future: context.read<CorpusRepository>().loadConfig(),
        builder: (context, snapshot) {
          final config = snapshot.data;
          if (config == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return BlocBuilder<SettingsCubit, AppSettings>(
            builder: (context, settings) =>
                _SettingsBody(config: config, settings: settings),
          );
        },
      ),
    );
  }
}

final class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.config, required this.settings});

  final CorpusConfig config;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appLang = settings.appLanguage ?? settings.nativeLanguage ?? 'fr';
    final native = config.languageByCode(settings.nativeLanguage ?? '');
    final target = config.languageByCode(settings.targetLanguage ?? 'en');
    final pairValue = (native == null || target == null)
        ? null
        : '${native.displayName(appLang)} → ${target.displayName(appLang)}';
    final reminder = TimeOfDay(
      hour: settings.reminderHour,
      minute: settings.reminderMinute,
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _Section(
          title: l10n.settingsPreferences,
          children: [
            _SettingsRow(
              icon: Icons.school_outlined,
              title: l10n.settingsSourceLanguage,
              value: pairValue,
              trailing: const Icon(Icons.lock_outline, size: AppSpacing.lg),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsComingSoon)),
              ),
            ),
            _SettingsRow(
              icon: Icons.language_outlined,
              title: l10n.settingsAppLanguage,
              value: config.languageByCode(appLang)?.nameNative,
              onTap: () => _pickAppLanguage(context, appLang),
            ),
            _SettingsRow(
              icon: Icons.notifications_outlined,
              title: l10n.settingsDailyReminder,
              value: reminder.format(context),
              onTap: () => _pickReminderTime(context, reminder),
            ),
            _NotificationsRow(settings: settings),
            _SettingsRow(
              icon: Icons.brightness_6_outlined,
              title: l10n.settingsTheme,
              value: _themeLabel(l10n, settings.themeMode),
              onTap: () => _pickTheme(context, settings.themeMode),
            ),
          ],
        ),
        const Sizer.xl(),
        _Section(
          title: l10n.settingsAbout,
          children: [
            _SettingsRow(
              icon: Icons.info_outline,
              title: l10n.settingsAboutApp,
              onTap: () => showAboutDialog(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: l10n.settingsVersion(_appVersion),
              ),
            ),
            _SettingsRow(
              icon: Icons.star_outline,
              title: l10n.settingsLeaveReview,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsComingSoon)),
              ),
            ),
          ],
        ),
        if (kDebugMode) ...[
          const Sizer.xl(),
          _Section(
            title: 'Debug',
            children: [
              _SettingsRow(
                icon: Icons.bug_report_outlined,
                title: 'Envoyer une notification test',
                onTap: () => context
                    .read<ReminderCoordinator>()
                    .showTodaysReminderNow(settings),
              ),
            ],
          ),
        ],
        const Sizer.xl(),
        Center(
          child: Text(
            '${l10n.appTitle} · ${l10n.settingsVersion(_appVersion)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  String _themeLabel(AppLocalizations l10n, AppThemeMode mode) => switch (mode) {
        AppThemeMode.system => l10n.settingsThemeSystem,
        AppThemeMode.light => l10n.settingsThemeLight,
        AppThemeMode.dark => l10n.settingsThemeDark,
      };

  Future<void> _pickAppLanguage(BuildContext context, String current) async {
    final cubit = context.read<SettingsCubit>();
    final codes = <String>{
      settings.nativeLanguage ?? 'fr',
      settings.targetLanguage ?? 'en',
    };
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final code in codes)
              if (config.languageByCode(code) case final info?)
                ListTile(
                  title: Text(info.nameNative),
                  trailing: code == current ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(sheetContext).pop(code),
                ),
          ],
        ),
      ),
    );
    if (selected != null) await cubit.setAppLanguage(selected);
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    TimeOfDay current,
  ) async {
    final cubit = context.read<SettingsCubit>();
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) await cubit.setReminderTime(picked.hour, picked.minute);
  }

  Future<void> _pickTheme(BuildContext context, AppThemeMode current) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SettingsCubit>();
    final selected = await showModalBottomSheet<AppThemeMode>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in AppThemeMode.values)
              ListTile(
                title: Text(_themeLabel(l10n, mode)),
                trailing: mode == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(sheetContext).pop(mode),
              ),
          ],
        ),
      ),
    );
    if (selected != null) await cubit.setThemeMode(selected);
  }
}

final class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final divided = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        divided.add(const Divider(
          height: AppSpacing.hairline,
          indent: AppSpacing.lg,
          endIndent: AppSpacing.lg,
        ));
      }
      divided.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Overline(title),
        const Sizer.s(),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(children: divided),
        ),
      ],
    );
  }
}

final class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.onSurfaceVariant),
            const Sizer.m(),
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
            if (value != null) ...[
              Text(
                value!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Sizer.xs(),
            ],
            if (trailing != null)
              IconTheme(
                data: IconThemeData(color: scheme.onSurfaceVariant),
                child: trailing!,
              )
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: AppSpacing.lg,
                color: scheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

/// Reflects the OS notification permission and offers a re-enable path for users
/// who declined at onboarding. Tapping while disabled re-requests permission,
/// then guides to the system settings if the OS won't prompt again.
final class _NotificationsRow extends StatefulWidget {
  const _NotificationsRow({required this.settings});

  final AppSettings settings;

  @override
  State<_NotificationsRow> createState() => _NotificationsRowState();
}

final class _NotificationsRowState extends State<_NotificationsRow>
    with WidgetsBindingObserver {
  NotificationPermission _status = NotificationPermission.notDetermined;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user may have flipped the switch in the system settings and returned.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final coordinator = context.read<ReminderCoordinator>();
    final status = await coordinator.permissionStatus();
    if (!mounted) return;
    final becameGranted = status == NotificationPermission.granted &&
        _status != NotificationPermission.granted;
    if (becameGranted) await coordinator.reschedule(widget.settings);
    if (!mounted) return;
    setState(() => _status = status);
  }

  Future<void> _handleTap() async {
    final coordinator = context.read<ReminderCoordinator>();
    switch (_status) {
      case NotificationPermission.notDetermined:
        // First time: show the native OS permission dialog.
        await coordinator.ensureEnabled(widget.settings);
        if (!mounted) return;
        await _refresh();
      case NotificationPermission.denied:
        // The OS won't prompt again; send the user to the system settings.
        // The result is picked up on resume via didChangeAppLifecycleState.
        await coordinator.openSystemSettings();
      case NotificationPermission.granted:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled = _status == NotificationPermission.granted;
    return _SettingsRow(
      icon: enabled
          ? Icons.notifications_active_outlined
          : Icons.notifications_off_outlined,
      title: l10n.settingsNotifications,
      value: enabled
          ? l10n.settingsNotificationsEnabled
          : l10n.settingsNotificationsDisabled,
      onTap: enabled ? null : _handleTap,
    );
  }
}
