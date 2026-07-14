import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/models/app_theme_mode.dart';

/// Drives the app's theme mode. Seeded from persisted settings in a later
/// milestone; defaults to following the OS.
class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit([super.initialState = AppThemeMode.system]);

  void setMode(AppThemeMode mode) => emit(mode);

  static ThemeMode toMaterial(AppThemeMode mode) => switch (mode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}
