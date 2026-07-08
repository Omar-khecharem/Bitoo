import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'preferences_provider.dart';
import 'app_theme.dart';

final accentColorsProvider = Provider<List<AccentColor>>((ref) => accentColors);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final prefs = ref.watch(preferencesProvider);
  return switch (prefs.themeMode) {
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.amoled => ThemeMode.dark,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.system => ThemeMode.system,
  };
});

final appThemeDataProvider = Provider<ThemeData>((ref) {
  final prefs = ref.watch(preferencesProvider);
  final isAmoled = prefs.themeMode == AppThemeMode.amoled;
  final accent = prefs.accentColor;

  return isAmoled
      ? AppTheme.amoled(accent: accent)
      : AppTheme.dark(accent: accent);
});

final appLightThemeDataProvider = Provider<ThemeData>((ref) {
  final accent = ref.watch(preferencesProvider).accentColor;
  return AppTheme.light(accent: accent);
});

final isAmoledProvider = Provider<bool>((ref) {
  return ref.watch(preferencesProvider).themeMode == AppThemeMode.amoled;
});
