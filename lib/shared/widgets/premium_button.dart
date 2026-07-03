import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/tokens.dart';

enum ButtonSize { sm, md, lg }

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = ButtonSize.md,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.micro,
      reverseDuration: AppDurations.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (height, horizontalPadding, radius) = switch (widget.size) {
      ButtonSize.sm => (40.0, Spacing.lg, AppRadius.md),
      ButtonSize.md => (48.0, Spacing.xl, AppRadius.lg),
      ButtonSize.lg => (56.0, Spacing.xxl, AppRadius.lg),
    };

    final textStyle = switch (widget.size) {
      ButtonSize.sm => AppTypography.labelMedium,
      ButtonSize.md => AppTypography.labelLarge,
      ButtonSize.lg => AppTypography.labelLarge,
    };

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: widget.onPressed != null
            ? (_) {
                _controller.forward();
              }
            : null,
        onTapUp: widget.onPressed != null
            ? (_) {
                _controller.reverse();
              }
            : null,
        onTapCancel: () {
          _controller.reverse();
        },
        onTap: widget.onPressed,
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: widget.onPressed != null ? AppShadows.glowPrimary : null,
          ),
          child: widget.isLoading ? _LoadingIndicator() : _ButtonContent(
            icon: widget.icon,
            label: widget.label,
            textStyle: textStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.textStyle,
    this.icon,
  });

  final String label;
  final TextStyle textStyle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppIconSizes.small, color: Colors.white),
          SizedBox(width: Spacing.sm),
          Text(label, style: textStyle),
        ],
      );
    }
    return Center(child: Text(label, style: textStyle));
  }
}

class _LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
    this.size = ButtonSize.md,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final (height, horizontalPadding, radius) = switch (size) {
      ButtonSize.sm => (40.0, Spacing.lg, AppRadius.md),
      ButtonSize.md => (48.0, Spacing.xl, AppRadius.lg),
      ButtonSize.lg => (56.0, Spacing.xxl, AppRadius.lg),
    };

    final textStyle = switch (size) {
      ButtonSize.sm => AppTypography.labelMedium,
      ButtonSize.md => AppTypography.labelLarge,
      ButtonSize.lg => AppTypography.labelLarge,
    };

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
          border: Border.all(
            color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: AppIconSizes.small),
                    SizedBox(width: Spacing.sm),
                    Text(label, style: textStyle),
                  ],
                )
              : Text(label, style: textStyle),
        ),
      ),
    );
  }
}

class PremiumIconButton extends StatelessWidget {
  const PremiumIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48.0,
    this.iconSize = AppIconSizes.medium,
    this.isActive = false,
    this.activeColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final bool isActive;
  final Color? activeColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? AppColors.primary500)
        : AppColors.darkTextSecondary;

    final button = GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
          border: Border.all(
            color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}

class PremiumTextButton extends StatelessWidget {
  const PremiumTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: color ?? AppColors.darkTextSecondary,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
