import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'splash_screen.dart';

/// The onboarding intro: shows the splash briefly, then advances to the first
/// step. Navigation is driven by the router.
final class OnboardingIntroScreen extends StatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

final class _OnboardingIntroScreenState extends State<OnboardingIntroScreen> {
  static const _introDuration = Duration(milliseconds: 1500);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_introDuration, () {
      if (mounted) context.go('/onboarding/language');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SplashScreen();
}
