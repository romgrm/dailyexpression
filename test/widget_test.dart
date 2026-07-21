import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/data/repositories/prefs_daily_log_repository.dart';
import 'package:daily_expression/data/repositories/settings_repository.dart';
import 'package:daily_expression/data/sources/corpus_local_data_source.dart';
import 'package:daily_expression/domain/models/scheduled_reminder.dart';
import 'package:daily_expression/domain/notifications/notification_scheduler.dart';
import 'package:daily_expression/domain/time/clock.dart';
import 'package:daily_expression/domain/use_cases/get_daily_expression.dart';
import 'package:daily_expression/domain/use_cases/plan_daily_reminders.dart';
import 'package:daily_expression/main.dart';
import 'package:daily_expression/ui/core/notifications/reminder_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No-op scheduler so the boot smoke test never touches platform channels.
class _NoopScheduler implements NotificationScheduler {
  const _NoopScheduler();
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async {}
  @override
  Future<void> cancelAll() async {}
}

void main() {
  testWidgets('App boots for an onboarded user', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'native_language': 'fr',
    });
    final prefs = await SharedPreferences.getInstance();
    final settingsRepository = SettingsRepository(prefs);
    final corpusRepository = CorpusRepository(CorpusLocalDataSource());
    final dailyLog = PrefsDailyLogRepository(prefs);
    const clock = SystemClock();

    await tester.pumpWidget(
      DailyExpressionApp(
        settingsRepository: settingsRepository,
        corpusRepository: corpusRepository,
        getDailyExpression: GetDailyExpression(
          log: dailyLog,
          clock: clock,
          userSeed: 'seed-test',
        ),
        reminderCoordinator: ReminderCoordinator(
          corpus: corpusRepository,
          log: dailyLog,
          planReminders:
              const PlanDailyReminders(clock: clock, userSeed: 'seed-test'),
          scheduler: const _NoopScheduler(),
        ),
        clock: clock,
        initialSettings: settingsRepository.read(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
