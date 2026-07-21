import 'package:daily_expression/domain/models/app_settings.dart';
import 'package:daily_expression/domain/models/scheduled_reminder.dart';
import 'package:daily_expression/domain/notifications/notification_scheduler.dart';
import 'package:daily_expression/domain/use_cases/plan_daily_reminders.dart';
import 'package:daily_expression/ui/core/notifications/reminder_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/corpus_mock.dart';
import '../../../support/fake_clock.dart';
import '../../../support/in_memory_daily_log.dart';

class _MockScheduler extends Mock implements NotificationScheduler {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(<ScheduledReminder>[]));

  ReminderCoordinator build(_MockScheduler scheduler) => ReminderCoordinator(
        corpus: buildMockCorpusRepository(),
        log: InMemoryDailyLog(),
        planReminders: PlanDailyReminders(
          clock: FakeClock(DateTime(2026, 7, 17, 6)),
          userSeed: 'seed-A',
        ),
        scheduler: scheduler,
      );

  const settings = AppSettings(
    nativeLanguage: 'fr',
    targetLanguage: 'en',
    appLanguage: 'fr',
    reminderHour: 8,
    reminderMinute: 0,
    onboardingComplete: true,
  );

  test('schedules 14 localized reminders teasing the target idiom', () async {
    final scheduler = _MockScheduler();
    when(() => scheduler.schedule(any())).thenAnswer((_) async {});
    when(() => scheduler.cancelAll()).thenAnswer((_) async {});

    await build(scheduler).reschedule(settings);

    final captured = verify(() => scheduler.schedule(captureAny()))
        .captured
        .single as List<ScheduledReminder>;

    expect(captured, hasLength(14));
    for (var i = 0; i < captured.length; i++) {
      expect(captured[i].id, i);
      expect(captured[i].scheduledAt.hour, 8);
      expect(captured[i].title, 'Ton expression du jour');
      expect(captured[i].body, startsWith('Aujourd\'hui : '));
      expect(captured[i].body.length, greaterThan('Aujourd\'hui : '.length));
    }
  });

  test('does nothing until a language pair is chosen', () async {
    final scheduler = _MockScheduler();
    await build(scheduler).reschedule(const AppSettings());
    verifyNever(() => scheduler.schedule(any()));
  });
}
