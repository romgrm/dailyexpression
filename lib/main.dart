import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/logging/app_log.dart';
import 'data/repositories/corpus_repository.dart';
import 'data/repositories/prefs_daily_log_repository.dart';
import 'data/repositories/prefs_streak_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/sources/corpus_local_data_source.dart';
import 'data/services/notification_service.dart';
import 'data/services/tts_speech_service.dart';
import 'domain/models/app_settings.dart';
import 'domain/repositories/streak_repository.dart';
import 'domain/speech/speech_synthesizer.dart';
import 'domain/time/clock.dart';
import 'domain/use_cases/get_daily_expression.dart';
import 'domain/use_cases/plan_daily_reminders.dart';
import 'l10n/generated/app_localizations.dart';
import 'ui/core/notifications/reminder_coordinator.dart';
import 'ui/core/router/app_router.dart';
import 'ui/core/settings/settings_cubit.dart';
import 'ui/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(prefs);
  final corpusRepository = CorpusRepository(CorpusLocalDataSource());
  final initialSettings = settingsRepository.read();
  final userSeed = await settingsRepository.ensureUserSeed();

  const clock = SystemClock();
  final dailyLog = PrefsDailyLogRepository(prefs);
  final streakRepository = PrefsStreakRepository(prefs);
  final getDailyExpression = GetDailyExpression(
    log: dailyLog,
    clock: clock,
    userSeed: userSeed,
  );
  final reminderCoordinator = ReminderCoordinator(
    corpus: corpusRepository,
    log: dailyLog,
    planReminders: PlanDailyReminders(clock: clock, userSeed: userSeed),
    scheduler: NotificationService(),
    settings: settingsRepository,
  );

  logger.d(
    '[bootstrap] onboardingComplete=${initialSettings.onboardingComplete}, '
    'native=${initialSettings.nativeLanguage}, theme=${initialSettings.themeMode.name}',
  );

  runApp(
    DailyExpressionApp(
      settingsRepository: settingsRepository,
      corpusRepository: corpusRepository,
      getDailyExpression: getDailyExpression,
      reminderCoordinator: reminderCoordinator,
      streakRepository: streakRepository,
      clock: clock,
      initialSettings: initialSettings,
    ),
  );
}

class DailyExpressionApp extends StatelessWidget {
  const DailyExpressionApp({
    super.key,
    required this.settingsRepository,
    required this.corpusRepository,
    required this.getDailyExpression,
    required this.reminderCoordinator,
    required this.streakRepository,
    required this.clock,
    required this.initialSettings,
  });

  final SettingsRepository settingsRepository;
  final CorpusRepository corpusRepository;
  final GetDailyExpression getDailyExpression;
  final ReminderCoordinator reminderCoordinator;
  final StreakRepository streakRepository;
  final Clock clock;
  final AppSettings initialSettings;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: settingsRepository),
        RepositoryProvider.value(value: corpusRepository),
        RepositoryProvider.value(value: getDailyExpression),
        RepositoryProvider.value(value: reminderCoordinator),
        RepositoryProvider<StreakRepository>.value(value: streakRepository),
        RepositoryProvider<Clock>.value(value: clock),
        RepositoryProvider<SpeechSynthesizer>(
          create: (_) => TtsSpeechService(),
        ),
      ],
      child: BlocProvider(
        create: (_) => SettingsCubit(settingsRepository, initialSettings),
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final _router = createRouter(context.read<SettingsCubit>());

  @override
  void initState() {
    super.initState();
    // Refresh the reminder window on every app open (history is frozen between
    // opens, so this keeps the imminent notification aligned with the card).
    final settings = context.read<SettingsCubit>().state;
    if (settings.onboardingComplete) {
      context.read<ReminderCoordinator>().reschedule(settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, AppSettings>(
      listenWhen: (previous, next) =>
          next.onboardingComplete &&
          (previous.onboardingComplete != next.onboardingComplete ||
              previous.reminderHour != next.reminderHour ||
              previous.reminderMinute != next.reminderMinute ||
              previous.appLanguage != next.appLanguage ||
              previous.nativeLanguage != next.nativeLanguage ||
              previous.targetLanguage != next.targetLanguage),
      listener: (context, settings) =>
          context.read<ReminderCoordinator>().reschedule(settings),
      child: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          final appLocale = settings.appLanguage ?? settings.nativeLanguage;
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode.material,
            locale: appLocale != null ? Locale(appLocale) : null,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              final preferred =
                  appLocale != null ? Locale(appLocale) : deviceLocale;
              if (preferred != null) {
                for (final locale in supportedLocales) {
                  if (locale.languageCode == preferred.languageCode) {
                    return locale;
                  }
                }
              }
              return const Locale('en');
            },
            routerConfig: _router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
