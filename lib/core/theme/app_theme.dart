import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary500,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary800,
      secondary: AppColors.secondary500,
      onSecondary: Colors.white,
      tertiary: AppColors.tertiary500,
      error: AppColors.error,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceLight,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkTextTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,

      // ─── Typography ───
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.darkTextPrimary),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkTextSecondary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.darkTextTertiary),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.darkTextSecondary),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.darkTextTertiary),
      ),

      // ─── AppBar ───
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: AppColors.darkTextPrimary),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary, size: AppIconSizes.medium),
      ),

      // ─── Bottom Navigation ───
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary500,
        unselectedItemColor: AppColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      // ─── Cards ───
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ─── Elevated Button ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.labelLarge.copyWith(color: Colors.white),
          shadowColor: AppColors.primary500.withValues(alpha: 0.3),
        ),
      ),

      // ─── Text Button ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkTextSecondary,
          padding: EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),

      // ─── Input Decoration ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
        contentPadding: EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: AppColors.primary500.withValues(alpha: 0.4)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.darkTextTertiary),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
      ),

      // ─── Snackbar ───
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceLight,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      // ─── Dialog ───
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),

      // ─── Bottom Sheet ───
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),

      // ─── Divider ───
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        thickness: 0.5,
        space: 0,
      ),

      // ─── Progress Indicator ───
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary500,
        linearTrackColor: AppColors.darkSurfaceLight,
      ),

      // ─── Slider ───
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary500,
        inactiveTrackColor: AppColors.darkTextTertiary.withValues(alpha: 0.3),
        thumbColor: Colors.white,
        overlayColor: AppColors.primary500.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
      ),

      // ─── Switch ───
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary500;
          return AppColors.darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary500.withValues(alpha: 0.4);
          return AppColors.darkSurfaceLight;
        }),
      ),

      // ─── Icon Theme ───
      iconTheme: IconThemeData(
        color: AppColors.darkTextSecondary,
        size: AppIconSizes.medium,
      ),

      // ─── Chip ───
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
        labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.darkTextPrimary),
        side: BorderSide(color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
        padding: EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      ),
    );
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary600,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary200,
      secondary: AppColors.secondary600,
      onSecondary: Colors.white,
      tertiary: AppColors.tertiary600,
      error: AppColors.error,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurfaceDark,
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.lightTextTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,

      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.lightTextPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.lightTextPrimary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.lightTextPrimary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.lightTextPrimary),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.lightTextPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.lightTextPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.lightTextPrimary),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.lightTextPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.lightTextSecondary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.lightTextTertiary),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.lightTextPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.lightTextSecondary),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.lightTextTertiary),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: AppColors.lightTextPrimary),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary, size: AppIconSizes.medium),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary600,
        unselectedItemColor: AppColors.lightTextTertiary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.04),
        contentPadding: EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: AppColors.primary600.withValues(alpha: 0.4)),
        ),
        hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.lightTextTertiary),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightSurfaceDark,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.06),
        thickness: 0.5,
        space: 0,
      ),

      iconTheme: IconThemeData(
        color: AppColors.lightTextSecondary,
        size: AppIconSizes.medium,
      ),
    );
  }
}
