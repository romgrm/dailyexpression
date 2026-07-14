import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_state.dart';

/// Holds the user's tentative onboarding choices. Step navigation is handled by
/// the router.
final class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void selectNative(String code) => emit(state.copyWith(nativeCode: code));

  void setReminderTime(int hour, int minute) =>
      emit(state.copyWith(reminderHour: hour, reminderMinute: minute));
}
