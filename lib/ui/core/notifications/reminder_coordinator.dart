import 'package:flutter/widgets.dart';

import '../../../data/repositories/corpus_repository.dart';
import '../../../domain/models/app_settings.dart';
import '../../../domain/models/language_pair.dart';
import '../../../domain/models/scheduled_reminder.dart';
import '../../../domain/notifications/notification_scheduler.dart';
import '../../../domain/repositories/daily_log_repository.dart';
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
  })  : _corpus = corpus,
        _log = log,
        _planReminders = planReminders,
        _scheduler = scheduler;

  final CorpusRepository _corpus;
  final DailyLogRepository _log;
  final PlanDailyReminders _planReminders;
  final NotificationScheduler _scheduler;

  /// Requests OS permission to post notifications. Returns whether granted.
  Future<bool> requestPermission() => _scheduler.requestPermission();

  /// Cancels the whole pending window.
  Future<void> cancelAll() => _scheduler.cancelAll();

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
          title: l10n.notificationDailyTitle,
          body: l10n.notificationDailyBody(
            planned[i].concept.forms[target]?.text ?? '',
          ),
        ),
    ];
    await _scheduler.schedule(reminders);
  }
}
