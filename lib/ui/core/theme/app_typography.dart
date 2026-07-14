import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the app text theme: Fraunces (serif) for display/titles — the brand
/// voice — and the platform sans for body and labels.
abstract final class AppTypography {
  AppTypography._();

  static TextTheme build(ColorScheme scheme) {
    final base = scheme.brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    final serif = GoogleFonts.frauncesTextTheme(base);

    TextStyle? display(TextStyle? style) =>
        style?.copyWith(fontWeight: FontWeight.w600);

    return base
        .copyWith(
          displayLarge: display(serif.displayLarge),
          displayMedium: display(serif.displayMedium),
          displaySmall: display(serif.displaySmall),
          headlineLarge: display(serif.headlineLarge),
          headlineMedium: display(serif.headlineMedium),
          headlineSmall: display(serif.headlineSmall),
          titleLarge: display(serif.titleLarge),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }
}
