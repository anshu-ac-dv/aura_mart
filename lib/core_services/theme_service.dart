import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void setSystemTheme() {
    themeMode.value = ThemeMode.system;
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;
  bool get isSystemMode => themeMode.value == ThemeMode.system;
}
