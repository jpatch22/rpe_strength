import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class persists user settings locally using the
/// shared_preferences package.
class SettingsService {
  static const String _themeModeKey = 'theme_mode';

  /// Loads the User's preferred ThemeMode from local storage.
  Future<ThemeMode> themeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);

    if (themeModeString == null) {
      return ThemeMode.system;
    }

    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == themeModeString,
      orElse: () => ThemeMode.system,
    );
  }

  /// Persists the user's preferred ThemeMode to local storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, theme.toString());
  }
}
