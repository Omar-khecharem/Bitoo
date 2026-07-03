import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand ───
  static const Color primary50 = Color(0xFFF5F3FF);
  static const Color primary100 = Color(0xFFEDE9FE);
  static const Color primary200 = Color(0xFFDDD6FE);
  static const Color primary300 = Color(0xFFC4B5FD);
  static const Color primary400 = Color(0xFFA78BFA);
  static const Color primary500 = Color(0xFF8B5CF6);
  static const Color primary600 = Color(0xFF7C3AED);
  static const Color primary700 = Color(0xFF6D28D9);
  static const Color primary800 = Color(0xFF5B21B6);
  static const Color primary900 = Color(0xFF4C1D95);

  static const Color secondary50 = Color(0xFFFFFBEB);
  static const Color secondary100 = Color(0xFFFEF3C7);
  static const Color secondary200 = Color(0xFFFDE68A);
  static const Color secondary300 = Color(0xFFFCD34D);
  static const Color secondary400 = Color(0xFFFBBF24);
  static const Color secondary500 = Color(0xFFF59E0B);
  static const Color secondary600 = Color(0xFFD97706);
  static const Color secondary700 = Color(0xFFB45309);

  static const Color tertiary50 = Color(0xFFFFF1F2);
  static const Color tertiary100 = Color(0xFFFFE4E6);
  static const Color tertiary200 = Color(0xFFFECDD3);
  static const Color tertiary300 = Color(0xFFFDA4AF);
  static const Color tertiary400 = Color(0xFFFB7185);
  static const Color tertiary500 = Color(0xFFF43F5E);
  static const Color tertiary600 = Color(0xFFE11D48);
  static const Color tertiary700 = Color(0xFFBE123C);

  // ─── Dark Mode ───
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurfaceDark = Color(0xFF12121A);
  static const Color darkSurface = Color(0xFF1C1C26);
  static const Color darkSurfaceLight = Color(0xFF262633);

  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextTertiary = Color(0xFF52525B);

  // ─── Light Mode ───
  static const Color lightBackground = Color(0xFFF8F8FA);
  static const Color lightSurfaceDark = Color(0xFFF0F0F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFFAFAFA);

  static const Color lightTextPrimary = Color(0xFF18181B);
  static const Color lightTextSecondary = Color(0xFF71717A);
  static const Color lightTextTertiary = Color(0xFFA1A1AA);

  // ─── Glass ───
  static Color glassBg(double opacity) => Colors.white.withValues(alpha: opacity);
  static Color glassBorder(double opacity) => Colors.white.withValues(alpha: opacity);
  static Color glassBgLight(double opacity) =>
      Colors.black.withValues(alpha: opacity);
  static Color glassBorderLight(double opacity) =>
      Colors.black.withValues(alpha: opacity);

  static const double glassOpacitySubtle = 0.05;
  static const double glassOpacityMedium = 0.10;
  static const double glassOpacityStrong = 0.15;
  static const double glassOpacityHeavy = 0.20;

  // ─── Semantic ───
  static const Color error = Color(0xFFF43F5E);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary500, Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premium = LinearGradient(
    colors: [AppColors.primary500, AppColors.tertiary500, AppColors.secondary500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient glassOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0x40000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient buttonHover = LinearGradient(
    colors: [AppColors.primary600, Color(0xFF4F46E5)],
  );
}

class DarkColors {
  DarkColors._();

  static const Color background = AppColors.darkBackground;
  static const Color surfaceDark = AppColors.darkSurfaceDark;
  static const Color surface = AppColors.darkSurface;
  static const Color surfaceLight = AppColors.darkSurfaceLight;
  static const Color textPrimary = AppColors.darkTextPrimary;
  static const Color textSecondary = AppColors.darkTextSecondary;
  static const Color textTertiary = AppColors.darkTextTertiary;
}

class LightColors {
  LightColors._();

  static const Color background = AppColors.lightBackground;
  static const Color surfaceDark = AppColors.lightSurfaceDark;
  static const Color surface = AppColors.lightSurface;
  static const Color surfaceLight = AppColors.lightSurfaceLight;
  static const Color textPrimary = AppColors.lightTextPrimary;
  static const Color textSecondary = AppColors.lightTextSecondary;
  static const Color textTertiary = AppColors.lightTextTertiary;
}

extension ContextColors on BuildContext {
  DarkColors get dark => DarkColors._();
  LightColors get light => LightColors._();
}
