import 'package:flutter/material.dart';

import '../../../domain/models/app_theme_mode.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Assembles the light and dark [ThemeData] from the Figma design tokens.
abstract final class AppTheme {
  AppTheme._();

  static ThemeData get light =>
      _build(lightColorScheme, AppColors.lightBackground);

  static ThemeData get dark => _build(darkColorScheme, AppColors.darkBackground);

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    primaryContainer: AppColors.lightAccent,
    onPrimaryContainer: AppColors.lightOnAccent,
    secondary: AppColors.lightPrimary,
    onSecondary: AppColors.lightOnPrimary,
    secondaryContainer: AppColors.lightAccent,
    onSecondaryContainer: AppColors.lightOnAccent,
    surface: AppColors.lightCard,
    onSurface: AppColors.lightForeground,
    surfaceContainerHighest: AppColors.lightMuted,
    onSurfaceVariant: AppColors.lightMutedForeground,
    outline: AppColors.lightMutedForeground,
    outlineVariant: AppColors.lightBorder,
    error: AppColors.lightError,
    onError: AppColors.lightOnError,
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    primaryContainer: AppColors.darkAccent,
    onPrimaryContainer: AppColors.darkOnAccent,
    secondary: AppColors.darkPrimary,
    onSecondary: AppColors.darkOnPrimary,
    secondaryContainer: AppColors.darkAccent,
    onSecondaryContainer: AppColors.darkOnAccent,
    surface: AppColors.darkCard,
    onSurface: AppColors.darkForeground,
    surfaceContainerHighest: AppColors.darkMuted,
    onSurfaceVariant: AppColors.darkMutedForeground,
    outline: AppColors.darkMutedForeground,
    outlineVariant: AppColors.darkBorder,
    error: AppColors.darkError,
    onError: AppColors.darkOnError,
  );

  static ThemeData _build(ColorScheme scheme, Color scaffoldBackground) {
    final textTheme = AppTypography.build(scheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Maps the domain [AppThemeMode] to Flutter's [ThemeMode].
extension AppThemeModeX on AppThemeMode {
  ThemeMode get material => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}
