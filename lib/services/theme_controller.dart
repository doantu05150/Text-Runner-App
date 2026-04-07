import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const String _prefsKey = 'theme_mode';

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefsKey);
    final mode = value == 'light' ? ThemeMode.light : ThemeMode.dark;
    _applyPalette(mode);
    themeMode.value = mode;
  }

  Future<void> setMode(ThemeMode mode) async {
    _applyPalette(mode);
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode == ThemeMode.light ? 'light' : 'dark');
  }

  void _applyPalette(ThemeMode mode) {
    if (mode == ThemeMode.light) {
      AppColors.applyLight();
    } else {
      AppColors.applyDark();
    }
  }

  bool get isDark => themeMode.value == ThemeMode.dark;
}
