class AnimationDurations {
  AnimationDurations._();
  static final AnimationDurations instance = AnimationDurations._();

  static const Duration micro = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration slower = Duration(milliseconds: 700);
  static const Duration slowest = Duration(milliseconds: 1000);

  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration pulse = Duration(milliseconds: 1200);
  static const Duration spinner = Duration(milliseconds: 800);
  static const Duration vinyl = Duration(milliseconds: 4000);
  static const Duration beat = Duration(milliseconds: 600);

  static const Duration staggerItem = Duration(milliseconds: 40);
  static const Duration staggerMax = Duration(milliseconds: 300);
}
