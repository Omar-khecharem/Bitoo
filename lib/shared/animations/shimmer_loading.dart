import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.shimmer,
    );
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) => CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _ShimmerPainter(
          progress: _shimmer.value,
          borderRadius: widget.borderRadius,
          baseColor: widget.baseColor ?? const Color(0xFF1C1C26),
          highlightColor: widget.highlightColor ?? const Color(0xFF262633),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;

  _ShimmerPainter({
    required this.progress,
    required this.borderRadius,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment(-1.0 + progress * 2, 0),
      end: Alignment(1.0 + progress * 2, 0),
      colors: [
        baseColor,
        highlightColor,
        baseColor,
      ],
      stops: [0.0, 0.5, 1.0],
    );

    canvas.drawRRect(
      rrect,
      Paint()..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class SkeletonCard extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonCard({
    super.key,
    this.width = double.infinity,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C26),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShimmerWidget(width: 72, height: 72, borderRadius: 12),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerWidget(width: double.infinity, height: 14, borderRadius: 4),
                        SizedBox(height: 8),
                        ShimmerWidget(width: 0.6, height: 12, borderRadius: 4),
                        SizedBox(height: 6),
                        ShimmerWidget(width: 0.4, height: 10, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ShimmerWidget(width: double.infinity, height: 10, borderRadius: 4),
              SizedBox(height: 6),
              ShimmerWidget(width: 0.8, height: 10, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final double crossAxisExtent;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisExtent = 160,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: crossAxisExtent,
          mainAxisExtent: 200,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(top: index < 2 ? 0 : 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerWidget(
                width: crossAxisExtent - 16,
                height: crossAxisExtent - 16,
                borderRadius: 16,
              ),
              SizedBox(height: 8),
              ShimmerWidget(
                width: crossAxisExtent * 0.7,
                height: 12,
                borderRadius: 4,
              ),
              SizedBox(height: 4),
              ShimmerWidget(
                width: crossAxisExtent * 0.5,
                height: 10,
                borderRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;

  const SkeletonList({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: List.generate(itemCount, (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              ShimmerWidget(width: 48, height: 48, borderRadius: 8),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(width: double.infinity, height: 14, borderRadius: 4),
                    SizedBox(height: 6),
                    ShimmerWidget(width: 0.5, height: 11, borderRadius: 4),
                  ],
                ),
              ),
              SizedBox(width: 12),
              ShimmerWidget(width: 32, height: 12, borderRadius: 4),
            ],
          ),
        )),
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration delay;

  const PulseDot({
    super.key,
    this.color = const Color(0xFF8B5CF6),
    this.size = 8,
    this.delay = Duration.zero,
  });

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.slower,
    );
    _pulse = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _pulse.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class LoadingDots extends StatelessWidget {
  final Color color;

  const LoadingDots({
    super.key,
    this.color = const Color(0xFF8B5CF6),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseDot(color: color, delay: Duration.zero),
        SizedBox(width: 6),
        PulseDot(color: color, delay: Duration(milliseconds: 200)),
        SizedBox(width: 6),
        PulseDot(color: color, delay: Duration(milliseconds: 400)),
      ],
    );
  }
}
