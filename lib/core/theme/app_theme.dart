import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF003E7E);
  static const Color primaryContainer = Color(0xFF1A56A0);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF3A5F95);
  static const Color background = Color(0xFFF7F9FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color onBackground = Color(0xFF191C1E);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF424751);
  static const Color outline = Color(0xFF737782);
  static const Color outlineVariant = Color(0xFFC2C6D3);
  static const Color error = Color(0xFFBA1A1A);
}

class AppTextStyles {
  static const TextStyle headlineXL = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.02 * 32,
    color: AppColors.onBackground,
  );

  static const TextStyle headlineLGMobile = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.onBackground,
  );

  static const TextStyle bodyMD = TextStyle(
    fontFamily: 'HankenGrotesk',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.onSurface,
  );

  static const TextStyle labelMD = TextStyle(
    fontFamily: 'HankenGrotesk',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.05 * 14,
  );

  static const TextStyle labelSM = TextStyle(
    fontFamily: 'HankenGrotesk',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.onSurfaceVariant,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'HankenGrotesk',
    );
  }
}
