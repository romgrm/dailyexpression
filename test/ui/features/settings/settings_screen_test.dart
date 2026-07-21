import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/data/repositories/settings_repository.dart';
import 'package:daily_expression/data/sources/corpus_local_data_source.dart';
import 'package:daily_expression/domain/models/app_theme_mode.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/settings/settings_cubit.dart';
import 'package:daily_expression/ui/features/settings/view/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders preferences and switches theme to Dark', (tester) async {
    SharedPreferences.setMockInitialValues({'native_language': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    final settingsRepo = SettingsRepository(prefs);
    final cubit = SettingsCubit(settingsRepo, settingsRepo.read());

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(
            value: CorpusRepository(CorpusLocalDataSource()),
          ),
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
