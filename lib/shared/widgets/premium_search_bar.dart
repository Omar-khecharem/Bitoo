import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/tokens.dart';

class PremiumSearchBar extends StatefulWidget {
  const PremiumSearchBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Artists, songs, or podcasts...',
    this.controller,
    this.autofocus = false,
    this.onFilterTap,
    this.large = false,
  });

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final TextEditingController? controller;
  final bool autofocus;
  final VoidCallback? onFilterTap;
  final bool large;

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: AppDurations.standard,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.large ? 56.0 : 52.0;
    final radius = widget.large ? AppRadius.xl : AppRadius.lg;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
          border: Border.all(
            color: _isFocused
                ? AppColors.primary500.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: _isFocused ? AppShadows.glowPrimary : null,
        ),
        child: TextField(
          controller: widget.controller,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: () {
            setState(() => _isFocused = true);
            _focusController.forward();
          },
          style: AppTypography.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: widget.large ? Spacing.lg : Spacing.md,
            ),
            hintText: widget.hintText,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.darkTextTertiary,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: AppIconSizes.small,
              color: AppColors.darkTextTertiary,
            ),
            suffixIcon: widget.onFilterTap != null
                ? IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      size: AppIconSizes.small,
                      color: AppColors.darkTextTertiary,
                    ),
                    onPressed: widget.onFilterTap,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
