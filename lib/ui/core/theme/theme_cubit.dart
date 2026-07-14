import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/models/app_theme_mode.dart';

/// Drives the app's theme mode (system / light / dark).
class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit([super.initialState = AppThemeMode.system]);

  void setMode(AppThemeMode mode) => emit(mode);

  static ThemeMode toMaterial(AppThemeMode mode) => switch (mode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}
