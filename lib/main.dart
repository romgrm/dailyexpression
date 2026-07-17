import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/logging/app_log.dart';
import 'data/repositories/corpus_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/sources/corpus_local_data_source.dart';
import 'domain/models/app_settings.dart';
import 'l10n/generated/app_localizations.dart';
import 'ui/core/router/app_router.dart';
import 'ui/core/settings/settings_cubit.dart';
import 'ui/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(prefs);
  final corpusRepository = CorpusRepository(CorpusLocalDataSource());
  final initialSettings = settingsRepository.read();
  logger.d(
    '[bootstrap] onboardingComplete=${initialSettings.onboardingComplete}, '
    'native=${initialSettings.nativeLanguage}, theme=${initialSettings.themeMode.name}',
  );

  runApp(
    DailyExpressionApp(
      settingsRepository: settingsRepository,
      corpusRepository: corpusRepository,
      initialSettings: initialSettings,
    ),
  );
}

class DailyExpressionApp extends StatelessWidget {
  const DailyExpressionApp({
    super.key,
    required this.settingsRepository,
    required this.corpusRepository,
    required this.initialSettings,
  });

  final SettingsRepository settingsRepository;
  final CorpusRepository corpusRepository;
  final AppSettings initialSettings;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: settingsRepository),
        RepositoryProvider.value(value: corpusRepository),
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
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, settings) {
        return MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode.material,
          routerConfig: _router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
