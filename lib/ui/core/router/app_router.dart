import 'package:go_router/go_router.dart';

import '../../features/onboarding/view/splash_screen.dart';

/// Builds the application's [GoRouter] configuration.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
    ],
  );
}
