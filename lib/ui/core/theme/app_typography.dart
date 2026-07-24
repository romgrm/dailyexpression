import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the app text theme following the brand: Lora (serif) for
/// display/titles/expressions — the brand voice — and DM Sans for body, labels
/// and UI.
abstract final class AppTypography {
  AppTypography._();

  static TextTheme build(ColorScheme scheme) {
    final base = scheme.brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    final serif = GoogleFonts.loraTextTheme(base);
    final sans = GoogleFonts.dmSansTextTheme(base);

    TextStyle? display(TextStyle? style) =>
        style?.copyWith(fontWeight: FontWeight.w600);

    return sans
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
