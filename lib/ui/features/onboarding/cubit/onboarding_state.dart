/// Transient onboarding choices, before they are persisted to settings.
final class OnboardingState {
  const OnboardingState({
    this.nativeCode,
    this.targetCode,
    this.reminderHour = 8,
    this.reminderMinute = 0,
  });

  final String? nativeCode;
  final String? targetCode;
  final int reminderHour;
  final int reminderMinute;

  OnboardingState copyWith({
    String? nativeCode,
    String? targetCode,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return OnboardingState(
      nativeCode: nativeCode ?? this.nativeCode,
      targetCode: targetCode ?? this.targetCode,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          other.nativeCode == nativeCode &&
          other.targetCode == targetCode &&
          other.reminderHour == reminderHour &&
          other.reminderMinute == reminderMinute;

  @override
  int get hashCode =>
      Object.hash(nativeCode, targetCode, reminderHour, reminderMinute);
}
