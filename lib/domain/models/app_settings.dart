import 'app_theme_mode.dart';

/// User preferences persisted across launches. Framework-free: reminder time is
/// stored as plain hour/minute ints (not a Flutter TimeOfDay).
class AppSettings {
  const AppSettings({
    this.nativeLanguage,
    this.targetLanguage,
    this.appLanguage,
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.themeMode = AppThemeMode.system,
    this.onboardingComplete = false,
  });

  /// The user's native (source) language code (e.g. 'fr', 'es'); null until
  /// chosen during onboarding. Defines the corpus pair and is not user-editable
  /// on the free tier (changing/adding pairs is a premium feature).
  final String? nativeLanguage;

  /// The language being learned (target of the corpus pair); null until chosen.
  final String? targetLanguage;

  /// The app UI (wording) language code; null until onboarding. Free users can
  /// switch it between their source and target languages, independently of the
  /// corpus pair.
  final String? appLanguage;
  final int reminderHour;
  final int reminderMinute;
  final AppThemeMode themeMode;
  final bool onboardingComplete;

  AppSettings copyWith({
    String? nativeLanguage,
    String? targetLanguage,
    String? appLanguage,
    int? reminderHour,
    int? reminderMinute,
    AppThemeMode? themeMode,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      appLanguage: appLanguage ?? this.appLanguage,
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
          other.targetLanguage == targetLanguage &&
          other.appLanguage == appLanguage &&
          other.reminderHour == reminderHour &&
          other.reminderMinute == reminderMinute &&
          other.themeMode == themeMode &&
          other.onboardingComplete == onboardingComplete;

  @override
  int get hashCode => Object.hash(
        nativeLanguage,
        targetLanguage,
        appLanguage,
        reminderHour,
        reminderMinute,
        themeMode,
        onboardingComplete,
      );
}
