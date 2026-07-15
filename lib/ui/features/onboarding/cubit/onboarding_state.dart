/// Transient onboarding choices, before they are persisted to settings.
final class OnboardingState {
  const OnboardingState({
    this.nativeCode,
    this.reminderHour = 8,
    this.reminderMinute = 0,
  });

  final String? nativeCode;
  final int reminderHour;
  final int reminderMinute;

  OnboardingState copyWith({
    String? nativeCode,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return OnboardingState(
      nativeCode: nativeCode ?? this.nativeCode,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          other.nativeCode == nativeCode &&
          other.reminderHour == reminderHour &&
          other.reminderMinute == reminderMinute;

  @override
  int get hashCode => Object.hash(nativeCode, reminderHour, reminderMinute);
}
