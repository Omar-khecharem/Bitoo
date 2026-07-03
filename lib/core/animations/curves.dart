import 'package:flutter/material.dart';

class AnimationCurves {
  AnimationCurves._();
  static final AnimationCurves instance = AnimationCurves._();

  static const Cubic premiumEase = Cubic(0.16, 1.0, 0.3, 1.0);
  static const Cubic premiumEaseOut = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Cubic premiumEaseIn = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Cubic emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Cubic glassReveal = Cubic(0.34, 1.56, 0.64, 1.0);

  static SpringDescription get spring => SpringDescription(
    damping: 0.7,
    stiffness: 300,
    mass: 1.0,
  );

  static SpringDescription get springBouncy => SpringDescription(
    damping: 0.5,
    stiffness: 200,
    mass: 1.0,
  );

  static SpringDescription get springSnappy => SpringDescription(
    damping: 0.8,
    stiffness: 500,
    mass: 0.5,
  );

  static const TransitionDuration transitionDuration = TransitionDuration();
}

class TransitionDuration {
  const TransitionDuration();

  Duration get push => Duration(milliseconds: 350);
  Duration get pop => Duration(milliseconds: 300);
  Duration get modal => Duration(milliseconds: 400);
}
