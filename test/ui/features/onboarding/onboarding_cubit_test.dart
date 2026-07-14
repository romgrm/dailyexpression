import 'package:bloc_test/bloc_test.dart';
import 'package:daily_expression/ui/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:daily_expression/ui/features/onboarding/cubit/onboarding_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingCubit', () {
    blocTest<OnboardingCubit, OnboardingState>(
      'selectNative stores the chosen code',
      build: OnboardingCubit.new,
      act: (cubit) => cubit.selectNative('fr'),
      expect: () => const [OnboardingState(nativeCode: 'fr')],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'setReminderTime updates the reminder time',
      build: OnboardingCubit.new,
      act: (cubit) => cubit.setReminderTime(7, 30),
      expect: () => const [
        OnboardingState(reminderHour: 7, reminderMinute: 30),
      ],
    );
  });
}
