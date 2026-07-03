import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/tokens.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    this.child,
    this.isLoading = true,
  });

  final Widget? child;
  final bool isLoading;

  factory ShimmerLoading.albumGrid({Key? key, int count = 4}) {
    return ShimmerLoading(
      key: key,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Spacing.pageHorizontal),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: Spacing.gridGap,
          mainAxisSpacing: Spacing.gridGap,
          childAspectRatio: 0.85,
        ),
        itemCount: count,
        itemBuilder: (_, __) => _AlbumCardSkeleton(),
      ),
    );
  }

  factory ShimmerLoading.artistRow({Key? key, int count = 4}) {
    return ShimmerLoading(
      key: key,
      child: SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: Spacing.pageHorizontal),
          itemCount: count,
          itemBuilder: (_, __) => Padding(
            padding: EdgeInsets.only(right: Spacing.lg),
            child: _ArtistCardSkeleton(),
          ),
        ),
      ),
    );
  }

  factory ShimmerLoading.list({Key? key, int count = 5}) {
    return ShimmerLoading(
      key: key,
      child: Column(
        children: List.generate(count, (_) => Padding(
          padding: EdgeInsets.only(bottom: Spacing.md),
          child: _ListTileSkeleton(),
        )),
      ),
    );
  }

  factory ShimmerLoading.banner({Key? key}) {
    return ShimmerLoading(
      key: key,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.pageHorizontal),
        child: _BannerSkeleton(),
      ),
    );
  }

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.shimmer,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child ?? SizedBox.shrink();
    if (widget.child != null) {
      return _ShimmerMask(animation: _animation, child: widget.child!);
    }
    return widget.child ?? SizedBox.shrink();
  }
}

class _ShimmerMask extends StatelessWidget {
  const _ShimmerMask({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF1C1C26),
                Color(0xFF262633),
                Color(0xFF1C1C26),
              ],
              stops: [
                animation.value,
                animation.value + 0.3,
                animation.value + 0.6,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: child!,
        );
      },
      child: child,
    );
  }
}

class _AlbumCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        SizedBox(height: Spacing.sm),
        Container(
          height: 14,
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 4),
        Container(
          height: 12,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _ArtistCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: Spacing.sm),
        Container(
          height: 14,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _ListTileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 4),
              Container(
                height: 12,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BannerSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}
