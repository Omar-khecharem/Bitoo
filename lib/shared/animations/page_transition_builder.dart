import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/curves.dart';

class PremiumSlideUpTransition extends StatelessWidget {
  final Widget child;

  const PremiumSlideUpTransition({
    super.key,
    required this.child,
  });

  static CustomTransitionPage buildPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _SlideUpPageTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      transitionDuration: AnimationCurves.transitionDuration.push,
      reverseTransitionDuration: AnimationCurves.transitionDuration.pop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SlideUpPageTransition(
      animation: ModalRoute.of(context)!.animation!,
      secondaryAnimation: ModalRoute.of(context)!.secondaryAnimation!,
      child: child,
    );
  }
}

class _SlideUpPageTransition extends StatefulWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _SlideUpPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  State<_SlideUpPageTransition> createState() => _SlideUpPageTransitionState();
}

class _SlideUpPageTransitionState extends State<_SlideUpPageTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationCurves.transitionDuration.push,
    );
    _slide = Tween<Offset>(
      begin: Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.premiumEaseOut,
    ));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationCurves.premiumEaseOut,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: widget.child,
        ),
      ),
    );
  }
}

class PremiumSharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const PremiumSharedAxisTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  static CustomTransitionPage buildPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return PremiumSharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      transitionDuration: AnimationCurves.transitionDuration.push,
      reverseTransitionDuration: AnimationCurves.transitionDuration.pop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([animation, secondaryAnimation]),
        builder: (context, child) {
          final isPush = animation.status == AnimationStatus.forward;
          final value =
              isPush ? animation.value : 1.0 - secondaryAnimation.value;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..translate(0.0, 0.0, (1.0 - value) * -100),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: child,
      ),
    );
  }
}

class PremiumZoomTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const PremiumZoomTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  static CustomTransitionPage buildPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return PremiumZoomTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      transitionDuration: AnimationCurves.transitionDuration.modal,
      reverseTransitionDuration: AnimationCurves.transitionDuration.pop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.92 + (animation.value * 0.08),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }
}

class PremiumFadeThroughTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const PremiumFadeThroughTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  static CustomTransitionPage buildPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return PremiumFadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      transitionDuration: AnimationCurves.transitionDuration.push,
      reverseTransitionDuration: AnimationCurves.transitionDuration.pop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.1, 0.9, curve: Curves.easeInOut),
          ),
        ),
        child: child,
      ),
    );
  }
}

class PageTransitionConfig {
  final Widget Function(Animation<double>, Animation<double>, Widget) builder;

  const PageTransitionConfig({required this.builder});

  static final slideUp = PageTransitionConfig(
    builder: (animation, secondary, child) => PremiumSharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondary,
      child: child,
    ),
  );

  static final zoom = PageTransitionConfig(
    builder: (animation, secondary, child) => PremiumZoomTransition(
      animation: animation,
      secondaryAnimation: secondary,
      child: child,
    ),
  );

  static final fadeThrough = PageTransitionConfig(
    builder: (animation, secondary, child) => PremiumFadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondary,
      child: child,
    ),
  );

  CustomTransitionPage buildPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          builder(animation, secondaryAnimation, child),
      transitionDuration: AnimationCurves.transitionDuration.push,
      reverseTransitionDuration: AnimationCurves.transitionDuration.pop,
    );
  }
}
