import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  static const String _themeKey = "theme_mode";

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeKey);
    if (savedMode == "dark") {
      themeMode.value = ThemeMode.dark;
    } else if (savedMode == "light") {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.system;
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, isDark ? "dark" : "light");
  }

  Future<void> setSystemTheme() async {
    themeMode.value = ThemeMode.system;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;
  bool get isSystemMode => themeMode.value == ThemeMode.system;
}
