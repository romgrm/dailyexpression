import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/app_log.dart';
import '../../features/daily/view/daily_view.dart';
import '../../features/onboarding/cubit/onboarding_cubit.dart';
import '../../features/onboarding/view/onboarding_intro_screen.dart';
import '../../features/onboarding/view/language_pick_screen.dart';
import '../../features/onboarding/view/reminders_screen.dart';
import '../../features/onboarding/view/target_confirm_screen.dart';
import '../../features/settings/view/settings_screen.dart';
import '../settings/settings_cubit.dart';

/// Builds the router. Onboarded users land on '/'; others are redirected into
/// the onboarding flow. The gate re-evaluates whenever settings change.
GoRouter createRouter(SettingsCubit settingsCubit) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _CubitRefresh(settingsCubit.stream),
    redirect: (context, state) {
      final onboarded = settingsCubit.state.onboardingComplete;
      final atOnboarding = state.matchedLocation.startsWith('/onboarding');
      final target = !onboarded && !atOnboarding
          ? '/onboarding'
          : onboarded && atOnboarding
              ? '/'
              : null;
      logger.d(
        '[router] redirect: ${state.matchedLocation} '
        '(onboarded=$onboarded) -> ${target ?? 'stay'}',
      );
      return target;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DailyView(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (_) => OnboardingCubit(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingIntroScreen(),
          ),
          GoRoute(
            path: '/onboarding/language',
            builder: (context, state) => const LanguagePickScreen(),
          ),
          GoRoute(
            path: '/onboarding/target',
            builder: (context, state) => const TargetConfirmScreen(),
          ),
          GoRoute(
            path: '/onboarding/reminders',
            builder: (context, state) => const RemindersScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Adapts a stream into a [Listenable] so GoRouter re-runs its redirect.
final class _CubitRefresh extends ChangeNotifier {
  _CubitRefresh(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
