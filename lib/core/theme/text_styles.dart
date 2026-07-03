import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String displayFont = 'Outfit';
  static const String bodyFont = 'Inter';
  static const String serifFont = 'Fraunces';

  // ─── Display ───
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFont,
    fontWeight: FontWeight.w700,
    fontSize: 52,
    height: 1.1,
    letterSpacing: -1.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFont,
    fontWeight: FontWeight.w700,
    fontSize: 40,
    height: 1.1,
    letterSpacing: -1.0,
  );

  // ─── Headlines ───
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: displayFont,
    fontWeight: FontWeight.w600,
    fontSize: 32,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: displayFont,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: displayFont,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // ─── Titles ───
  static const TextStyle titleLarge = TextStyle(
    fontFamily: displayFont,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: displayFont,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.4,
    letterSpacing: -0.1,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: displayFont,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.4,
    letterSpacing: -0.1,
  );

  // ─── Body ───
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.6,
    letterSpacing: 0.0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0.0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.5,
    letterSpacing: 0.0,
  );

  // ─── Labels ───
  static const TextStyle labelLarge = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.4,
    letterSpacing: 0.3,
  );
}

extension ContextTypography on BuildContext {
  AppTypography get typography => AppTypography._();
}
