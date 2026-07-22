import 'package:daily_expression/data/repositories/settings_repository.dart';
import 'package:daily_expression/domain/models/app_theme_mode.dart';
import 'package:daily_expression/domain/models/scheduled_reminder.dart';
import 'package:daily_expression/domain/notifications/notification_scheduler.dart';
import 'package:daily_expression/domain/time/clock.dart';
import 'package:daily_expression/domain/use_cases/plan_daily_reminders.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/notifications/reminder_coordinator.dart';
import 'package:daily_expression/ui/core/settings/settings_cubit.dart';
import 'package:daily_expression/ui/features/settings/view/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/corpus_mock.dart';
import '../../../support/in_memory_daily_log.dart';

class _NoopScheduler implements NotificationScheduler {
  const _NoopScheduler();
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> openSystemSettings() async {}
  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async {}
  @override
  Future<void> showNow(ScheduledReminder reminder) async {}
  @override
  Future<void> cancelAll() async {}
}

void main() {
  testWidgets('renders preferences and switches theme to Dark', (tester) async {
    SharedPreferences.setMockInitialValues({'native_language': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    final settingsRepo = SettingsRepository(prefs);
    final cubit = SettingsCubit(settingsRepo, settingsRepo.read());
    final corpus = buildMockCorpusRepository();
    final coordinator = ReminderCoordinator(
      corpus: corpus,
      log: InMemoryDailyLog(),
      planReminders:
          const PlanDailyReminders(clock: SystemClock(), userSeed: 'seed-test'),
      scheduler: const _NoopScheduler(),
      settings: settingsRepo,
    );

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: corpus),
          RepositoryProvider.value(value: coordinator),
        ],
        child: BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            locale: Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PRÉFÉRENCES'), findsOneWidget);
    expect(find.text('Thème'), findsOneWidget);

    await tester.tap(find.text('Thème'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sombre'));
    await tester.pumpAndSettle();

    expect(cubit.state.themeMode, AppThemeMode.dark);
  });
}
