import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Music-inspired vibrant core palette ───
  // Warm, joyful, artistic — like a music festival painting
  static const Color vibrantAmber = Color(0xFFFF8C00);
  static const Color vibrantCoral = Color(0xFFFF6B6B);
  static const Color vibrantGold = Color(0xFFFFD700);
  static const Color vibrantTeal = Color(0xFF00C9A7);
  static const Color vibrantMagenta = Color(0xFFE040FB);
  static const Color vibrantOrange = Color(0xFFFF6D00);
  static const Color vibrantPurple = Color(0xFF9C27B0);
  static const Color vibrantWarmPink = Color(0xFFFF4081);

  // ─── Accent color variants ───
  static Color primary500 = vibrantAmber;
  static Color primary300 = const Color(0xFFFFB74D);
  static Color primary700 = const Color(0xFFE65100);
  static Color secondary500 = vibrantCoral;
  static Color tertiary500 = vibrantMagenta;

  // ─── Dark Mode (warm, deep) ───
  static const Color darkBackground = Color(0xFF1A1210);
  static const Color darkSurfaceDark = Color(0xFF221A18);
  static const Color darkSurface = Color(0xFF2A2220);
  static const Color darkSurfaceLight = Color(0xFF352D2B);

  static const Color darkTextPrimary = Color(0xFFFFF8F0);
  static const Color darkTextSecondary = Color(0xFFD4C5B8);
  static const Color darkTextTertiary = Color(0xFF8A7A6E);

  // ─── AMOLED Mode ───
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A0808);
  static const Color amoledSurfaceLight = Color(0xFF141110);
  static const Color amoledSurfaceCard = Color(0xFF1A1614);

  // ─── Light Mode (warm, airy) ───
  static const Color lightBackground = Color(0xFFFFFBF5);
  static const Color lightSurfaceDark = Color(0xFFF5EDE4);
  static const Color lightSurface = Color(0xFFFFFEFC);
  static const Color lightSurfaceLight = Color(0xFFFFF9F0);

  static const Color lightTextPrimary = Color(0xFF2C1810);
  static const Color lightTextSecondary = Color(0xFF6B5A4E);
  static const Color lightTextTertiary = Color(0xFFA69588);

  // ─── Glass ───
  static Color glassDark(double opacity) => const Color(0xFF1A1210).withValues(alpha: opacity);
  static Color glassLight(double opacity) => const Color(0xFFFFFBF5).withValues(alpha: opacity * 0.8);
  static Color glassBorderDark(double opacity) => Colors.white.withValues(alpha: opacity);
  static Color glassBorderLight(double opacity) => Colors.black.withValues(alpha: opacity * 0.15);

  static const double glassOpacitySubtle = 0.05;
  static const double glassOpacityMedium = 0.10;
  static const double glassOpacityStrong = 0.15;
  static const double glassOpacityHeavy = 0.20;

  // ─── Semantic ───
  static const Color error = Color(0xFFFF4D6D);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF00E0FF);

  // ─── Backward-compat getters ───
  static Color get neonIndigo => primary500;
  static Color get neonRose => secondary500;
  static Color get neonBlue => tertiary500;

  static void applyAccent({
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) {
    primary500 = primary;
    secondary500 = secondary;
    tertiary500 = tertiary;
  }

  static void resetAccent() {
    primary500 = vibrantAmber;
    secondary500 = vibrantCoral;
    tertiary500 = vibrantMagenta;
  }
}

class AppGradients {
  AppGradients._();

  static LinearGradient warmSunset = LinearGradient(
    colors: [AppColors.vibrantAmber, AppColors.vibrantCoral],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient sunsetToMagenta = LinearGradient(
    colors: [AppColors.vibrantAmber, AppColors.vibrantMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient coralToGold = LinearGradient(
    colors: [AppColors.vibrantCoral, AppColors.vibrantGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient warmPurple = LinearGradient(
    colors: [AppColors.vibrantPurple, AppColors.vibrantWarmPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient premium = LinearGradient(
    colors: [AppColors.vibrantAmber, AppColors.vibrantCoral, AppColors.vibrantMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static LinearGradient glassOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0x80000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient get primary => warmSunset;
  static LinearGradient get blueToIndigo => warmSunset;
  static LinearGradient get indigoToRose => sunsetToMagenta;
}


