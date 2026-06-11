import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that manages the application's theme mode and persists it locally.
class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  /// Reactive notifier for the current theme mode.
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  static const String _themeKey = "theme_mode";
  SharedPreferences? _prefs;

  /// Initializes the service by loading the saved theme mode from persistent storage.
  /// This should be called before [runApp].
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedMode = _prefs?.getString(_themeKey);
      
      if (savedMode == "dark") {
        themeMode.value = ThemeMode.dark;
      } else if (savedMode == "light") {
        themeMode.value = ThemeMode.light;
      } else {
        themeMode.value = ThemeMode.system;
      }
    } catch (e) {
      debugPrint("ThemeService Initialization Error: $e");
      // Fallback to system theme if storage fails
      themeMode.value = ThemeMode.system;
    }
  }

  /// Sets the theme to either [ThemeMode.dark] or [ThemeMode.light].
  /// Persists the choice to local storage.
  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (themeMode.value == newMode) return;

    themeMode.value = newMode;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_themeKey, isDark ? "dark" : "light");
    } catch (e) {
      debugPrint("ThemeService Toggle Error: $e");
    }
  }

  /// Reverts the theme to follow the system settings.
  /// Removes the persisted choice from local storage.
  Future<void> setSystemTheme() async {
    if (themeMode.value == ThemeMode.system) return;

    themeMode.value = ThemeMode.system;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.remove(_themeKey);
    } catch (e) {
      debugPrint("ThemeService Reset Error: $e");
    }
  }

  /// Helper getters for the current state.
  bool get isDarkMode => themeMode.value == ThemeMode.dark;
  bool get isSystemMode => themeMode.value == ThemeMode.system;
}
