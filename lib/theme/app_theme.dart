import 'package:flutter/material.dart';

class _Palette {
  final Color bgMain;
  final Color bgCard;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color primarySoft;
  final Color border;

  const _Palette({
    required this.bgMain,
    required this.bgCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.primarySoft,
    required this.border,
  });
}

const _darkPalette = _Palette(
  bgMain: Color(0xFF0B0F14),
  bgCard: Color(0xFF121821),
  textPrimary: Color.fromRGBO(255, 255, 255, 0.9),
  textSecondary: Color.fromRGBO(255, 255, 255, 0.6),
  textMuted: Color.fromRGBO(255, 255, 255, 0.4),
  primary: Color(0xFFDFFF4F),
  primarySoft: Color.fromRGBO(223, 255, 79, 0.15),
  border: Color.fromRGBO(255, 255, 255, 0.1),
);

const _lightPalette = _Palette(
  bgMain: Color(0xFFF6F7FB),
  bgCard: Color(0xFFFFFFFF),
  textPrimary: Color.fromRGBO(0, 0, 0, 0.9),
  textSecondary: Color.fromRGBO(0, 0, 0, 0.6),
  textMuted: Color.fromRGBO(0, 0, 0, 0.4),
  primary: Color(0xFF7A9E00),
  primarySoft: Color.fromRGBO(122, 158, 0, 0.12),
  border: Color.fromRGBO(0, 0, 0, 0.1),
);

class AppColors {
  static Color bgMain = _darkPalette.bgMain;
  static Color bgCard = _darkPalette.bgCard;
  static Color textPrimary = _darkPalette.textPrimary;
  static Color textSecondary = _darkPalette.textSecondary;
  static Color textMuted = _darkPalette.textMuted;
  static Color primary = _darkPalette.primary;
  static Color primarySoft = _darkPalette.primarySoft;
  static Color border = _darkPalette.border;

  static bool _isDark = true;
  static bool get isDark => _isDark;

  static void applyDark() => _apply(_darkPalette, true);
  static void applyLight() => _apply(_lightPalette, false);

  static void _apply(_Palette p, bool dark) {
    bgMain = p.bgMain;
    bgCard = p.bgCard;
    textPrimary = p.textPrimary;
    textSecondary = p.textSecondary;
    textMuted = p.textMuted;
    primary = p.primary;
    primarySoft = p.primarySoft;
    border = p.border;
    _isDark = dark;
  }
}

class AppTheme {
  static ThemeData get current {
    final base = AppColors.isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgMain,
      cardColor: AppColors.bgCard,
      colorScheme: (AppColors.isDark
              ? const ColorScheme.dark()
              : const ColorScheme.light())
          .copyWith(
        primary: AppColors.primary,
        surface: AppColors.bgCard,
        onPrimary: AppColors.isDark ? Colors.black : Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgCard,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: AppColors.textPrimary),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
        ),
      ),
    );
  }
}
