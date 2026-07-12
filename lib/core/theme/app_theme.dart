import 'package:flutter/material.dart';
import 'color_schemes.dart';

// ─── AccentColor for the 8 selector swatches ───
class AccentColor {
  final String name;
  final Color color;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color label;

  const AccentColor({
    required this.name,
    required this.color,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    this.label = Colors.white,
  });

  static const AccentColor festival = AccentColor(
    name: 'Festival',
    color: Color(0xFFFFB300),
    primary: Color(0xFFFFB300),
    secondary: Color(0xFFFF6F00),
    tertiary: Color(0xFFE040FB),
  );
}

const List<AccentColor> accentColors = [
  AccentColor(
    name: 'Festival',
    color: Color(0xFFFFB300),
    primary: Color(0xFFFFB300),
    secondary: Color(0xFFFF6F00),
    tertiary: Color(0xFFE040FB),
  ),
  AccentColor(
    name: 'Sunset',
    color: Color(0xFFFF6D00),
    primary: Color(0xFFFF6D00),
    secondary: Color(0xFFFF4081),
    tertiary: Color(0xFF9C27B0),
  ),
  AccentColor(
    name: 'Jazz',
    color: Color(0xFF9C27B0),
    primary: Color(0xFF9C27B0),
    secondary: Color(0xFFFFD700),
    tertiary: Color(0xFFE040FB),
  ),
  AccentColor(
    name: 'Tropical',
    color: Color(0xFF00C9A7),
    primary: Color(0xFF00C9A7),
    secondary: Color(0xFFFFB300),
    tertiary: Color(0xFFFF6B6B),
  ),
  AccentColor(
    name: 'Electric',
    color: Color(0xFF2979FF),
    primary: Color(0xFF2979FF),
    secondary: Color(0xFFE040FB),
    tertiary: Color(0xFFFF4081),
  ),
  AccentColor(
    name: 'Rock',
    color: Color(0xFFFF3D00),
    primary: Color(0xFFFF3D00),
    secondary: Color(0xFFFF9100),
    tertiary: Color(0xFFFFAB00),
  ),
  AccentColor(
    name: 'Classic',
    color: Color(0xFFD4AF37),
    primary: Color(0xFFD4AF37),
    secondary: Color(0xFF8B4513),
    tertiary: Color(0xFF800020),
    label: Color(0xFF2C1810),
  ),
  AccentColor(
    name: 'Midnight',
    color: Color(0xFF304FFE),
    primary: Color(0xFF304FFE),
    secondary: Color(0xFF00BCD4),
    tertiary: Color(0xFF7C4DFF),
  ),
];

class AppTheme {
  AppTheme._();

  static ThemeData dark({AccentColor? accent}) {
    final a = accent ?? accentColors[0];
    AppColors.applyAccent(
        primary: a.primary, secondary: a.secondary, tertiary: a.tertiary);

    final colorScheme = ColorScheme.dark(
      primary: a.primary,
      secondary: a.secondary,
      tertiary: a.tertiary,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
      outline: AppColors.darkTextTertiary.withValues(alpha: 0.5),
      surfaceTint: a.primary,
    );

    return _baseTheme(colorScheme: colorScheme, isDark: true);
  }

  static ThemeData light({AccentColor? accent}) {
    final a = accent ?? accentColors[0];
    AppColors.applyAccent(
        primary: a.primary, secondary: a.secondary, tertiary: a.tertiary);

    final colorScheme = ColorScheme.light(
      primary: a.primary,
      secondary: a.secondary,
      tertiary: a.tertiary,
      surface: AppColors.lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.error,
      outline: AppColors.lightTextTertiary.withValues(alpha: 0.4),
      surfaceTint: a.primary,
    );

    return _baseTheme(colorScheme: colorScheme, isDark: false);
  }

  static ThemeData amoled({AccentColor? accent}) {
    final a = accent ?? accentColors[0];
    AppColors.applyAccent(
        primary: a.primary, secondary: a.secondary, tertiary: a.tertiary);

    final colorScheme = ColorScheme.dark(
      primary: a.primary,
      secondary: a.secondary,
      tertiary: a.tertiary,
      surface: AppColors.amoledBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
      outline: AppColors.amoledSurfaceLight.withValues(alpha: 0.8),
      surfaceTint: a.primary,
    );

    return _baseTheme(colorScheme: colorScheme, isDark: true);
  }

  static ThemeData _baseTheme({
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface =
        isDark ? AppColors.amoledSurfaceCard : AppColors.lightSurface;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,

      // ─── Cards ───
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: Colors.transparent,
      ),

      // ─── AppBar ───
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // ─── Bottom Sheet ───
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ─── Dialog ───
      dialogTheme: DialogTheme(
        backgroundColor:
            isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      // ─── Text ───
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        titleLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        labelSmall: TextStyle(
          color: textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),

      // ─── Icon ───
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),

      // ─── Divider ───
      dividerTheme: DividerThemeData(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.08),
        thickness: 0.5,
      ),

      // ─── Snackbar ───
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceDark,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ─── Slider ───
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.12),
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),

      // ─── Switch ───
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return isDark
              ? AppColors.darkTextTertiary
              : AppColors.lightTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.4);
          }
          return isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.12);
        }),
      ),

      // ─── Input ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppColors.amoledSurfaceCard : AppColors.lightSurfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
          color:
              isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        ),
      ),

      // ─── Chip ───
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.amoledSurfaceCard : AppColors.lightSurfaceDark,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // ─── PopupMenu ───
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ─── Page Transitions ───
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // ─── NavigationBar (NavigationBar) ───
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceDark,
        elevation: 0,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return TextStyle(
            color: textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
    );
  }
}
