import 'app_theme_mode.dart';

/// User preferences persisted across launches. Framework-free: reminder time is
/// stored as plain hour/minute ints (not a Flutter TimeOfDay).
class AppSettings {
  const AppSettings({
    this.nativeLanguage,
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.themeMode = AppThemeMode.system,
    this.onboardingComplete = false,
  });

  /// The user's native language code (e.g. 'fr', 'es'); null until chosen
  /// during onboarding.
  final String? nativeLanguage;
  final int reminderHour;
  final int reminderMinute;
  final AppThemeMode themeMode;
  final bool onboardingComplete;

  AppSettings copyWith({
    String? nativeLanguage,
    int? reminderHour,
    int? reminderMinute,
    AppThemeMode? themeMode,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      themeMode: themeMode ?? this.themeMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.nativeLanguage == nativeLanguage &&
          other.reminderHour == reminderHour &&
          other.reminderMinute == reminderMinute &&
          other.themeMode == themeMode &&
          other.onboardingComplete == onboardingComplete;

  @override
  int get hashCode => Object.hash(
        nativeLanguage,
        reminderHour,
        reminderMinute,
        themeMode,
        onboardingComplete,
      );
}
