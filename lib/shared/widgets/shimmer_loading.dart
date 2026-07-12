import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    this.child,
    this.isLoading = true,
  });

  final Widget? child;
  final bool isLoading;

  static Widget albumGrid({Key? key, int count = 4}) {
    return _ThemedShimmer(
      key: key,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: count,
        itemBuilder: (_, __) => _AlbumCardSkeleton(),
      ),
    );
  }

  static Widget artistRow({Key? key, int count = 4}) {
    return _ThemedShimmer(
      key: key,
      child: SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: count,
          itemBuilder: (_, __) => Padding(
            padding: EdgeInsets.only(right: 16),
            child: _ArtistCardSkeleton(),
          ),
        ),
      ),
    );
  }

  static Widget list({Key? key, int count = 5}) {
    return _ThemedShimmer(
      key: key,
      child: Column(
        children: List.generate(
            count,
            (_) => Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _ListTileSkeleton(),
                )),
      ),
    );
  }

  static Widget banner({Key? key}) {
    return _ThemedShimmer(
      key: key,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
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
      duration: const Duration(milliseconds: 1500),
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
    if (!widget.isLoading) return widget.child ?? const SizedBox.shrink();
    if (widget.child != null) {
      return _ShimmerMask(animation: _animation, child: widget.child!);
    }
    return const SizedBox.shrink();
  }
}

class _ThemedShimmer extends StatelessWidget {
  final Widget child;

  const _ThemedShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: child,
    );
  }
}

class _ShimmerMask extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _ShimmerMask({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1C1C26) : const Color(0xFFE8E0D8);
    final shimmer = isDark ? const Color(0xFF262633) : const Color(0xFFF0EAE2);

    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, shimmer, base],
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
    final c = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: c.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 14,
          width: 100,
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 4),
        Container(
          height: 12,
          width: 60,
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.5),
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
    final c = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 14,
          width: 60,
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.5),
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
    final c = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 4),
              Container(
                height: 12,
                width: 100,
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: 0.5),
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
    final c = Theme.of(context).colorScheme;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
