import 'package:flutter/material.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/color_schemes.dart';

class HomeSection extends StatelessWidget {
  const HomeSection({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    required this.child,
    this.padding,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(bottom: Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.pageHorizontal),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.titleLarge,
                  ),
                ),
                if (actionLabel != null && onAction != null)
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionLabel!,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: Spacing.md),
          child,
        ],
      ),
    );
  }
}
