import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/tokens.dart';

class PremiumSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    PremiumSnackbarType type = PremiumSnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = AppDurations.snackbar,
  }) {
    final color = switch (type) {
      PremiumSnackbarType.success => AppColors.success,
      PremiumSnackbarType.error => AppColors.error,
      PremiumSnackbarType.warning => AppColors.warning,
      PremiumSnackbarType.info => AppColors.info,
    };

    final icon = switch (type) {
      PremiumSnackbarType.success => Icons.check_circle_rounded,
      PremiumSnackbarType.error => Icons.error_rounded,
      PremiumSnackbarType.warning => Icons.warning_rounded,
      PremiumSnackbarType.info => Icons.info_rounded,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              Icon(icon, size: AppIconSizes.small, color: color),
              SizedBox(width: Spacing.md),
              Expanded(
                child: Text(message, style: AppTypography.bodyMedium),
              ),
              if (actionLabel != null)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onAction?.call();
                  },
                  child: Text(
                    actionLabel,
                    style: AppTypography.labelMedium.copyWith(color: color),
                  ),
                ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(
          Spacing.lg,
          0,
          Spacing.lg,
          MediaQuery.of(context).padding.bottom + 80,
        ),
      ),
    );
  }
}

enum PremiumSnackbarType { success, error, warning, info }

class PremiumDialog extends StatelessWidget {
  const PremiumDialog({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  final IconData? icon;
  final String? title;
  final String? description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  static Future<bool?> show({
    required BuildContext context,
    IconData? icon,
    String? title,
    String? description,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => PremiumDialog(
        icon: icon,
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 320,
            padding: EdgeInsets.all(Spacing.xl),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              border: Border.all(
                color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.shadowLG,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDestructive
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.primary500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: isDestructive ? AppColors.error : AppColors.primary500,
                      size: 24,
                    ),
                  ),
                  SizedBox(height: Spacing.lg),
                ],
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTypography.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Spacing.sm),
                ],
                if (description != null) ...[
                  Text(
                    description!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Spacing.xl),
                ],
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(false);
                          onCancel?.call();
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Center(
                            child: Text(
                              cancelLabel,
                              style: AppTypography.labelLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Spacing.md),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(true);
                          onConfirm?.call();
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: isDestructive
                                ? LinearGradient(colors: [AppColors.error, AppColors.tertiary600])
                                : AppGradients.primary,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Center(
                            child: Text(
                              confirmLabel,
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
