import 'curves.dart';
import 'durations.dart';

class AnimationTokens {
  AnimationTokens._();

  static AnimationDurations get duration => AnimationDurations.instance;
  static AnimationCurves get curve => AnimationCurves.instance;
}
