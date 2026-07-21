import 'package:daily_expression/data/repositories/settings_repository.dart';
import 'package:daily_expression/domain/models/app_settings.dart';
import 'package:daily_expression/domain/models/app_theme_mode.dart';
import 'package:daily_expression/ui/core/settings/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsRepository repo;
  late SettingsCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = SettingsRepository(await SharedPreferences.getInstance());
    cubit = SettingsCubit(repo, const AppSettings());
  });

  test('setThemeMode updates state and persists', () async {
    await cubit.setThemeMode(AppThemeMode.dark);
    expect(cubit.state.themeMode, AppThemeMode.dark);
    expect(repo.read().themeMode, AppThemeMode.dark);
  });

  test('setNativeLanguage updates state and persists', () async {
    await cubit.setNativeLanguage('es');
    expect(cubit.state.nativeLanguage, 'es');
    expect(repo.read().nativeLanguage, 'es');
  });

  test('setReminderTime updates state and persists', () async {
    await cubit.setReminderTime(7, 30);
    expect(cubit.state.reminderHour, 7);
    expect(cubit.state.reminderMinute, 30);
    expect(repo.read().reminderHour, 7);
  });
}
