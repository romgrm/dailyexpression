import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_expression/core/logging/app_log.dart';
import 'package:daily_expression/data/repositories/settings_repository.dart';
import 'package:daily_expression/domain/models/app_settings.dart';
import 'package:daily_expression/domain/models/app_theme_mode.dart';

/// Holds the app-wide [AppSettings] and persists changes. Also the router's
/// source of truth for the onboarding gate.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository, super.initialState);

  final SettingsRepository _repository;

  Future<void> _persist(AppSettings next) async {
    await _repository.save(next);
    emit(next);
    logger.d(
      '[settings] saved: onboarding=${next.onboardingComplete}, '
      'native=${next.nativeLanguage}, theme=${next.themeMode.name}, '
      'reminder=${next.reminderHour}:${next.reminderMinute}',
    );
  }

  Future<void> completeOnboarding({
    required String nativeLanguage,
    required String targetLanguage,
    required int reminderHour,
    required int reminderMinute,
  }) {
    return _persist(
      state.copyWith(
        nativeLanguage: nativeLanguage,
        targetLanguage: targetLanguage,
        appLanguage: nativeLanguage,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
        onboardingComplete: true,
      ),
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      _persist(state.copyWith(themeMode: mode));

  Future<void> setAppLanguage(String code) =>
      _persist(state.copyWith(appLanguage: code));

  Future<void> setReminderTime(int hour, int minute) =>
      _persist(state.copyWith(reminderHour: hour, reminderMinute: minute));
}
