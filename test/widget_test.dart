import 'package:daily_expression/data/repositories/corpus_repository.dart';
import 'package:daily_expression/data/repositories/settings_repository.dart';
import 'package:daily_expression/data/sources/corpus_local_data_source.dart';
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

    await tester.pumpWidget(
      DailyExpressionApp(
        settingsRepository: settingsRepository,
        corpusRepository: CorpusRepository(CorpusLocalDataSource()),
        initialSettings: settingsRepository.read(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
