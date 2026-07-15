import 'package:daily_expression/data/repositories/settings_repository.dart';
import 'package:daily_expression/domain/models/app_settings.dart';
import 'package:daily_expression/domain/models/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SettingsRepository> buildRepo([
    Map<String, Object> initial = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository(prefs);
  }

  test('returns defaults when nothing is stored', () async {
    final repo = await buildRepo();
    final settings = repo.read();

    expect(settings.nativeLanguage, isNull);
    expect(settings.reminderHour, 8);
    expect(settings.reminderMinute, 0);
    expect(settings.themeMode, AppThemeMode.system);
    expect(settings.onboardingComplete, isFalse);
  });

  test('persists and reads settings back', () async {
    final repo = await buildRepo();
    const settings = AppSettings(
      nativeLanguage: 'fr',
      reminderHour: 7,
      reminderMinute: 30,
      themeMode: AppThemeMode.dark,
      onboardingComplete: true,
    );

    await repo.save(settings);

    expect(repo.read(), settings);
  });

  test('falls back to system theme for an unknown stored value', () async {
    final repo = await buildRepo({'theme_mode': 'nonsense'});
    expect(repo.read().themeMode, AppThemeMode.system);
  });
}
