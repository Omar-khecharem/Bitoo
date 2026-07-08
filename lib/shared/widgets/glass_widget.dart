import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/color_schemes.dart';

class GlassWidget extends StatelessWidget {
  const GlassWidget({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.lg,
    this.opacity = AppColors.glassOpacityMedium,
    this.blur = 20,
    this.borderOpacity = AppColors.glassOpacityMedium,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  final Widget child;
  final double borderRadius;
  final double opacity;
  final double blur;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.glassDark(opacity)
                  : AppColors.glassLight(opacity),
              border: Border.all(
                color: isDark
                    ? AppColors.glassBorderDark(borderOpacity)
                    : AppColors.glassBorderLight(borderOpacity),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    this.child,
    this.borderRadius = AppRadius.lg,
    this.opacity = AppColors.glassOpacityMedium,
    this.blur = 20,
    this.borderOpacity = AppColors.glassOpacityMedium,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.gradient,
    this.onTap,
  });

  final Widget? child;
  final double borderRadius;
  final double opacity;
  final double blur;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final container = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: gradient != null
                ? null
                : isDark
                    ? AppColors.glassDark(opacity)
                    : AppColors.glassLight(opacity),
            gradient: gradient,
            border: Border.all(
              color: isDark
                  ? AppColors.glassBorderDark(borderOpacity)
                  : AppColors.glassBorderLight(borderOpacity),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }
    return container;
  }
}
