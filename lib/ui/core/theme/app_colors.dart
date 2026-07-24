import 'package:flutter/material.dart';

/// Raw design tokens exported from the Figma theme (light + dark).
///
/// These are the visual source of truth and supersede the approximate palette
/// described in the product skill. Consumed by [AppTheme] to build the
/// Material [ColorScheme]s; avoid referencing these directly from widgets —
/// use `Theme.of(context).colorScheme` instead.
abstract final class AppColors {
  AppColors._();

  // ---- Light ----
  static const lightBackground = Color(0xFFFAF8F4);
  static const lightForeground = Color(0xFF1C1917);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF1B6B6B);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightAccent = Color(0xFFEBF5F5);
  static const lightOnAccent = Color(0xFF1B6B6B);
  static const lightMuted = Color(0xFFF0EDE8);
  static const lightMutedForeground = Color(0xFF8B7E74);
  static const lightBorder = Color(0x141C1917); // rgba(28,25,23,0.08)
  static const lightError = Color(0xFFD4183D);
  static const lightOnError = Color(0xFFFFFFFF);

  // ---- Dark ----
  static const darkBackground = Color(0xFF1C1917); // "Encre chaude"
  static const darkForeground = Color(0xFFF5F0EB);
  static const darkCard = Color(0xFF26221F);
  static const darkPrimary = Color(0xFF4DB6AC);
  static const darkOnPrimary = Color(0xFF0E2626);
  static const darkAccent = Color(0xFF1A2E2E);
  static const darkOnAccent = Color(0xFF4DB6AC);
  static const darkMuted = Color(0xFF262320);
  static const darkMutedForeground = Color(0xFF8B8073);
  static const darkBorder = Color(0x12F5F0EB); // rgba(245,240,235,0.07)
  static const darkError = Color(0xFFF2B8B5);
  static const darkOnError = Color(0xFF601410);

  // ---- Supplementary: gold CEFR badge (not in the Figma variable set) ----
  static const goldBadgeBackground = Color(0xFFF7ECC8);
  static const goldBadgeText = Color(0xFF8A6D1B);
  static const goldBadgeBackgroundDark = Color(0xFF3A3320);
  static const goldBadgeTextDark = Color(0xFFE3C778);

  // ---- Supplementary: streak flame (not in the Figma variable set) ----
  static const flame = Color(0xFFE2572B);
  static const flameBackground = Color(0xFFFCE9E1);
  static const flameDark = Color(0xFFF07A52);
  static const flameBackgroundDark = Color(0xFF3A241C);

  // ---- Brand: the two-raindrop mark ----
  static const brandTeal = Color(0xFF1B6B6B); // "Teal profond"
  static const brandTealMid = Color(0xFF2A8080); // "Teal mi-ton"
  static const brandCream = Color(0xFFFAF8F4); // "Crème"
  static const brandCreamSoft = Color(0xFFEAE3D6); // warmer cream for the drops
  static const brandInk = Color(0xFF1C1917); // "Encre" — dark-mode logo bg
  static const brandMist = Color(0xFFC5BFB8); // "Brume"
}
