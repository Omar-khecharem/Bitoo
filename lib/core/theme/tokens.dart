import 'package:flutter/material.dart';

export 'text_styles.dart';

class Spacing {
  Spacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double x3l = 48;
  static const double x4l = 64;
  static const double x5l = 96;

  static const double pageHorizontal = xl;
  static const double pageVertical = xl;
  static const double cardInset = lg;
  static const double sectionSpacing = xxl;
  static const double gridGap = lg;
}

class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;
}

class AppDurations {
  AppDurations._();

  static const Duration micro = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration complex = Duration(milliseconds: 500);
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration snackbar = Duration(seconds: 4);
  static const Duration debounce = Duration(milliseconds: 300);
}

class AppIconSizes {
  AppIconSizes._();

  static const double micro = 16;
  static const double small = 20;
  static const double medium = 24;
  static const double large = 28;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 80;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> shadowSM = const [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMD = const [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLG = const [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowPrimary = const [
    BoxShadow(
      color: Color(0x408B5CF6),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x208B5CF6),
      blurRadius: 40,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowGlass = const [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
}

enum Breakpoint {
  phone,
  tablet,
  desktop;

  static Breakpoint fromWidth(double width) {
    if (width >= 840) return Breakpoint.desktop;
    if (width >= 600) return Breakpoint.tablet;
    return Breakpoint.phone;
  }
}
