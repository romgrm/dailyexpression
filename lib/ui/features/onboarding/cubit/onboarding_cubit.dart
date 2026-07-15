import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_expression/core/logging/app_log.dart';
import 'onboarding_state.dart';

/// Holds the user's tentative onboarding choices. Step navigation is handled by
/// the router.
final class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void selectNative(String code) {
    logger.d('[onboarding] native selected: $code');
    emit(state.copyWith(nativeCode: code));
  }

  void setReminderTime(int hour, int minute) {
    logger.d('[onboarding] reminder time -> $hour:$minute');
    emit(state.copyWith(reminderHour: hour, reminderMinute: minute));
  }
}
