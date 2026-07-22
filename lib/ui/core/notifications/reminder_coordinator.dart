import 'package:flutter/widgets.dart';

import '../../../data/repositories/corpus_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/models/app_settings.dart';
import '../../../domain/models/concept.dart';
import '../../../domain/models/language_pair.dart';
import '../../../domain/models/scheduled_reminder.dart';
import '../../../domain/notifications/notification_permission.dart';
import '../../../domain/notifications/notification_scheduler.dart';
import '../../../domain/repositories/daily_log_repository.dart';
import '../../../domain/time/clock.dart';
import '../../../domain/use_cases/daily_selection.dart';
import '../../../domain/use_cases/plan_daily_reminders.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Orchestrates the local reminder window: pulls the pool and history, projects
/// the next days through [PlanDailyReminders], localizes each into a
/// [ScheduledReminder], and hands them to the [NotificationScheduler].
///
/// Rescheduled on every app open and whenever the reminder time or language
/// changes, so the imminent notification always teases the concept the card
/// will reveal next.
class ReminderCoordinator {
  ReminderCoordinator({
    required CorpusRepository corpus,
    required DailyLogRepository log,
    required PlanDailyReminders planReminders,
    required NotificationScheduler scheduler,
    required SettingsRepository settings,
  })  : _corpus = corpus,
        _log = log,
        _planReminders = planReminders,
        _scheduler = scheduler,
        _settings = settings;

  final CorpusRepository _corpus;
  final DailyLogRepository _log;
  final PlanDailyReminders _planReminders;
  final NotificationScheduler _scheduler;
  final SettingsRepository _settings;

  /// Requests OS permission to post notifications. Returns whether granted.
  /// Records the attempt so the UI knows the OS won't prompt again.
  Future<bool> requestPermission() async {
    await _settings.markNotificationPermissionRequested();
    return _scheduler.requestPermission();
  }

  /// The current permission state, folding the OS authorization together with
  /// our persisted "already asked" flag (the OS can't reliably tell us apart
  /// [NotificationPermission.notDetermined] from [NotificationPermission.denied]).
  Future<NotificationPermission> permissionStatus() async {
    if (await _scheduler.hasPermission()) return NotificationPermission.granted;
    return _settings.hasRequestedNotificationPermission()
        ? NotificationPermission.denied
        : NotificationPermission.notDetermined;
  }

  /// Opens the OS notification settings page for this app.
  Future<void> openSystemSettings() => _scheduler.openSystemSettings();

  /// Requests permission and, when granted, reschedules the window. Returns
  /// whether notifications ended up enabled.
  Future<bool> ensureEnabled(AppSettings settings) async {
    final granted = await requestPermission();
    if (granted) await reschedule(settings);
    return granted;
  }

  /// Cancels the whole pending window.
  Future<void> cancelAll() => _scheduler.cancelAll();

  /// A daily-rotating catchy title, deterministic per [dayKey] so the same
  /// title shows all day and matches the scheduled notification.
  String _rotatingTitle(AppLocalizations l10n, String dayKey) {
    final titles = <String>[
      l10n.notificationTitle1,
      l10n.notificationTitle2,
      l10n.notificationTitle3,
      l10n.notificationTitle4,
      l10n.notificationTitle5,
      l10n.notificationTitle6,
    ];
    return titles[stableHash('title|$dayKey') % titles.length];
  }

  /// Debug aid: posts TODAY's reminder right now — the very concept the card is
  /// showing (read from the daily log) — so permission, content, and rendering
  /// can be checked without waiting for the scheduled time.
  Future<void> showTodaysReminderNow(AppSettings settings) async {
    final native = settings.nativeLanguage;
    final target = settings.targetLanguage;
    if (native == null || target == null) return;

    await _scheduler.requestPermission();
    final pair = LanguagePair(native: native, target: target);
    final pool = await _corpus.availableConcepts(pair);

    final logged = await _log.forDay(dayKeyOf(DateTime.now()), pair.glossKey);
    if (logged == null) return;
    Concept? concept;
    for (final c in pool) {
      if (c.id == logged.conceptId) {
        concept = c;
        break;
      }
    }
    if (concept == null) return;

    final l10n = lookupAppLocalizations(Locale(settings.appLanguage ?? native));
    await _scheduler.showNow(
      ScheduledReminder(
        id: 999,
        scheduledAt: DateTime.now(),
        title: _rotatingTitle(l10n, dayKeyOf(DateTime.now())),
        body: l10n.notificationDailyBody(
          concept.forms[target]?.text ?? '',
        ),
      ),
    );
  }

  /// Rebuilds and reschedules the reminder window for [settings]. A no-op until
  /// a language pair has been chosen.
  Future<void> reschedule(AppSettings settings) async {
    final native = settings.nativeLanguage;
    final target = settings.targetLanguage;
    if (native == null || target == null) return;

    final pair = LanguagePair(native: native, target: target);
    final pool = await _corpus.availableConcepts(pair);
    final history = await _log.history(pair.glossKey);

    final planned = _planReminders(
      pair: pair,
      pool: pool,
      history: history,
      reminderHour: settings.reminderHour,
      reminderMinute: settings.reminderMinute,
    );
    if (planned.isEmpty) {
      await _scheduler.cancelAll();
      return;
    }

    final l10n = lookupAppLocalizations(Locale(settings.appLanguage ?? native));
    final reminders = <ScheduledReminder>[
      for (var i = 0; i < planned.length; i++)
        ScheduledReminder(
          id: i,
          scheduledAt: planned[i].scheduledAt,
          title: _rotatingTitle(l10n, dayKeyOf(planned[i].scheduledAt)),
          body: l10n.notificationDailyBody(
            planned[i].concept.forms[target]?.text ?? '',
          ),
        ),
    ];
    await _scheduler.schedule(reminders);
  }
}
