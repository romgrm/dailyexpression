import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/data/repositories/prefs_daily_log_repository.dart';
import 'package:daily_expression/data/repositories/settings_repository.dart';
import 'package:daily_expression/data/sources/corpus_local_data_source.dart';
import 'package:daily_expression/domain/time/clock.dart';
import 'package:daily_expression/domain/use_cases/get_daily_expression.dart';
import 'package:daily_expression/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots for an onboarded user', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'native_language': 'fr',
    });
    final prefs = await SharedPreferences.getInstance();
    final settingsRepository = SettingsRepository(prefs);
    const clock = SystemClock();

    await tester.pumpWidget(
      DailyExpressionApp(
        settingsRepository: settingsRepository,
        corpusRepository: CorpusRepository(CorpusLocalDataSource()),
        getDailyExpression: GetDailyExpression(
          log: PrefsDailyLogRepository(prefs),
          clock: clock,
          userSeed: 'seed-test',
        ),
        clock: clock,
        initialSettings: settingsRepository.read(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
