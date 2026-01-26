import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/user/presentation/providers/user_preferences_provider.dart';
import 'modern_app_theme.dart';

final themeProvider = Provider<ThemeData>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  final appTheme = ModernAppTheme();

  return preferences.isDarkMode
      ? appTheme.getDarkTheme()
      : appTheme.getTheme();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light;
});
