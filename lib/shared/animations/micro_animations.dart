import 'package:flutter/material.dart';
import '../../core/animations/curves.dart';
import '../../core/theme/tokens.dart';

class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final double scaleUp;
  final Duration duration;

  const ScaleOnTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.96,
    this.scaleUp = 1.0,
    this.duration = AppDurations.micro,
  });

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scale = Tween<double>(begin: widget.scaleUp, end: widget.scaleDown)
        .animate(CurvedAnimation(parent: _controller, curve: AnimationCurves.premiumEase));
  }

  @override
  void didUpdateWidget(ScaleOnTap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class ScaleOnTapStatic extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ScaleOnTapStatic({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onTap,
      child: child,
    );
  }
}

class TapFlash extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TapFlash({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<TapFlash> createState() => _TapFlashState();
}

class _TapFlashState extends State<TapFlash>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _opacity = ValueNotifier(0.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _opacity.value = 0.3,
      onTapUp: (_) {
        _opacity.value = 0.0;
        widget.onTap?.call();
      },
      onTapCancel: () => _opacity.value = 0.0,
      child: ValueListenableBuilder<double>(
        valueListenable: _opacity,
        builder: (context, opacity, child) => AnimatedOpacity(
          opacity: 1.0 - opacity,
          duration: AppDurations.fast,
          child: Container(
            foregroundDecoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PulseEffect extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration period;

  const PulseEffect({
    super.key,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 1.03,
    this.period = AppDurations.pulse,
  });

  @override
  State<PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<PulseEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period);
    _pulse = Tween<double>(begin: widget.minScale, end: widget.maxScale)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
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
      builder: (context, child) => Transform.scale(
        scale: _pulse.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}

class PressRipple extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PressRipple({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<PressRipple> createState() => _PressRippleState();
}

class _PressRippleState extends State<PressRipple>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  final ValueNotifier<Offset?> _tapPosition = ValueNotifier(null);

  @override
  void dispose() {
    _tapPosition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTapDown: (details) => _tapPosition.value = details.localPosition,
        onTapUp: (_) => _tapPosition.value = null,
        onTapCancel: () => _tapPosition.value = null,
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }
}

class GlassHover extends StatefulWidget {
  final Widget child;
  final double hoverOpacity;

  const GlassHover({
    super.key,
    required this.child,
    this.hoverOpacity = 0.15,
  });

  @override
  State<GlassHover> createState() => _GlassHoverState();
}

class _GlassHoverState extends State<GlassHover> {
  final ValueNotifier<bool> _isHovered = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isHovered,
        builder: (context, isHovered, child) => AnimatedContainer(
          duration: AppDurations.fast,
          curve: AnimationCurves.premiumEase,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withValues(
              alpha: isHovered ? widget.hoverOpacity : 0.0,
            ),
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class HeartBounce extends StatefulWidget {
  final bool isFilled;
  final VoidCallback? onTap;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const HeartBounce({
    super.key,
    required this.isFilled,
    this.onTap,
    this.size = 24,
    this.activeColor = const Color(0xFFF43F5E),
    this.inactiveColor = const Color(0xFFA1A1AA),
  });

  @override
  State<HeartBounce> createState() => _HeartBounceState();
}

class _HeartBounceState extends State<HeartBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.premiumEase,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0);
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _bounce,
        builder: (context, child) => Transform.scale(
          scale: _bounce.value,
          child: child,
        ),
        child: Icon(
          widget.isFilled ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          size: widget.size,
          color: widget.isFilled ? widget.activeColor : widget.inactiveColor,
        ),
      ),
    );
  }
}

class ChevronRotate extends StatelessWidget {
  final bool isExpanded;
  final double size;
  final Color? color;

  const ChevronRotate({
    super.key,
    required this.isExpanded,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: isExpanded ? 0.5 : 0.0,
      duration: AppDurations.fast,
      curve: AnimationCurves.premiumEase,
      child: Icon(
        Icons.chevron_right_rounded,
        size: size,
        color: color ?? Colors.white.withValues(alpha: 0.5),
      ),
    );
  }
}

class AnimatedToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor = const Color(0xFF8B5CF6),
    this.inactiveColor = const Color(0xFF52525B),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AnimationCurves.premiumEase,
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: AppDurations.fast,
          curve: AnimationCurves.premiumEase,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.all(2),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PulseRing extends StatefulWidget {
  final Color color;
  final double size;
  final double maxRadius;

  const PulseRing({
    super.key,
    this.color = const Color(0xFF8B5CF6),
    this.size = 24,
    this.maxRadius = 40,
  });

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.slower,
    );
    _ring = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
      animation: _ring,
      builder: (context, child) => CustomPaint(
        size: Size(widget.maxRadius * 2, widget.maxRadius * 2),
        painter: _RingPainter(
          progress: _ring.value,
          color: widget.color,
        ),
        child: Center(child: child),
      ),
      child: Icon(Icons.play_arrow_rounded, size: widget.size, color: Colors.white),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 * progress;

    final paint = Paint()
      ..color = color.withValues(alpha: (1.0 - progress) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class NumberPop extends StatelessWidget {
  final int value;
  final TextStyle? style;

  const NumberPop({
    super.key,
    required this.value,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: AppDurations.normal,
      curve: AnimationCurves.premiumEaseOut,
      builder: (context, value, _) => Text(
        '$value',
        style: style,
      ),
    );
  }
}

class StaggeredFadeIn extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;

  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = AppDurations.staggerItem,
  });

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.premiumEaseOut),
    );
    _slide = Tween<Offset>(
      begin: Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.premiumEaseOut,
    ));

    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: widget.child,
      ),
    );
  }
}
