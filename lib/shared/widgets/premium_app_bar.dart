import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/tokens.dart';

class PremiumAppBar extends StatefulWidget {
  const PremiumAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.titleWidget,
    this.largeTitle = false,
    this.scrollController,
    this.onBack,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? titleWidget;
  final bool largeTitle;
  final ScrollController? scrollController;
  final VoidCallback? onBack;

  @override
  State<PremiumAppBar> createState() => _PremiumAppBarState();
}

class _PremiumAppBarState extends State<PremiumAppBar> {
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(PremiumAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final offset = widget.scrollController?.offset ?? 0;
    if (offset != _scrollOffset) {
      setState(() => _scrollOffset = offset);
    }
  }

  double get _glassOpacity {
    if (_scrollOffset <= 0) return 0;
    if (_scrollOffset >= 40) return 1.0;
    return _scrollOffset / 40;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20 * _glassOpacity,
          sigmaY: 20 * _glassOpacity,
        ),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: AppColors.glassOpacityHeavy * _glassOpacity),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium * _glassOpacity),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: widget.largeTitle ? 96 : 64,
              padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Row(
                children: [
                  if (widget.leading != null || widget.onBack != null)
                    Padding(
                      padding: EdgeInsets.only(right: Spacing.sm),
                      child: widget.leading ??
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                            onPressed: widget.onBack,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                              shape: CircleBorder(),
                            ),
                          ),
                    ),
                  Expanded(
                    child: widget.titleWidget ??
                        Text(
                          widget.title ?? '',
                          style: widget.largeTitle
                              ? AppTypography.headlineLarge
                              : AppTypography.headlineSmall,
                        ),
                  ),
                  if (widget.actions != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.actions!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
