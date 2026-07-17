import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_settings.dart';
import '../../domain/models/app_theme_mode.dart';

/// Reads and writes [AppSettings] to local storage. [read] is synchronous so
/// startup can resolve the initial route without an async gap.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _nativeLanguageKey = 'native_language';
  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinuteKey = 'reminder_minute';
  static const _themeModeKey = 'theme_mode';
  static const _onboardingCompleteKey = 'onboarding_complete';
  static const _userSeedKey = 'user_seed';

  AppSettings read() {
    return AppSettings(
      nativeLanguage: _prefs.getString(_nativeLanguageKey),
      reminderHour: _prefs.getInt(_reminderHourKey) ?? 8,
      reminderMinute: _prefs.getInt(_reminderMinuteKey) ?? 0,
      themeMode: _themeModeFromName(_prefs.getString(_themeModeKey)),
      onboardingComplete: _prefs.getBool(_onboardingCompleteKey) ?? false,
    );
  }

  Future<void> save(AppSettings settings) async {
    final native = settings.nativeLanguage;
    if (native != null) {
      await _prefs.setString(_nativeLanguageKey, native);
    }
    await _prefs.setInt(_reminderHourKey, settings.reminderHour);
    await _prefs.setInt(_reminderMinuteKey, settings.reminderMinute);
    await _prefs.setString(_themeModeKey, settings.themeMode.name);
    await _prefs.setBool(_onboardingCompleteKey, settings.onboardingComplete);
  }

  static AppThemeMode _themeModeFromName(String? name) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => AppThemeMode.system,
    );
  }

  /// Returns the stable per-user seed, generating and persisting one on first
  /// call. This is the identity that makes the daily stream reproducible and
  /// that a future backend will sync to link a local install to an account.
  Future<String> ensureUserSeed() async {
    final existing = _prefs.getString(_userSeedKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final seed = _generateSeed();
    await _prefs.setString(_userSeedKey, seed);
    return seed;
  }

  static String _generateSeed() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
