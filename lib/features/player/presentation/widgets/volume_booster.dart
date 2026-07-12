import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class VolumeBooster extends StatefulWidget {
  final double volume;
  final ValueChanged<double> onChanged;

  const VolumeBooster({super.key, required this.volume, required this.onChanged});

  @override
  State<VolumeBooster> createState() => _VolumeBoosterState();
}

class _VolumeBoosterState extends State<VolumeBooster>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const double maxVolume = 2.0;
  static const double minVolume = 0.0;
  static const double step = 0.05;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (isBoosted) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(VolumeBooster old) {
    super.didUpdateWidget(old);
    if (isBoosted && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isBoosted && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get isBoosted => widget.volume > 1.0;
  double get displayLevel => (widget.volume / maxVolume).clamp(0.0, 1.0);

  void _decrease() => widget.onChanged((widget.volume - step).clamp(minVolume, maxVolume));
  void _increase() => widget.onChanged((widget.volume + step).clamp(minVolume, maxVolume));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: isBoosted
                ? AppColors.neonRose.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isBoosted
                  ? AppColors.neonRose.withValues(alpha: 0.2 * _pulseAnimation.value)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 4),
              _VolumeButton(
                text: '\u2212',
                onTap: _decrease,
                isBoosted: isBoosted,
              ),
              SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: displayLevel,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                colors: isBoosted
                                    ? [AppColors.neonRose, Colors.orangeAccent]
                                    : [AppColors.neonIndigo, AppColors.neonBlue],
                              ),
                              boxShadow: isBoosted
                                  ? [
                                      BoxShadow(
                                        color: AppColors.neonRose.withValues(alpha: 0.4 * _pulseAnimation.value),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: AppColors.neonIndigo.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBoosted ? 'BOOST' : 'VOL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isBoosted
                                ? AppColors.neonRose.withValues(alpha: 0.8 * _pulseAnimation.value)
                                : Colors.white.withValues(alpha: 0.25),
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '\u00d7${widget.volume.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isBoosted
                                ? AppColors.neonRose
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: Spacing.sm),
              _VolumeButton(
                text: '+',
                onTap: _increase,
                isBoosted: isBoosted,
              ),
              SizedBox(width: 4),
            ],
          ),
        );
      },
    );
  }
}

class _VolumeButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isBoosted;

  const _VolumeButton({
    required this.text,
    required this.onTap,
    this.isBoosted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isBoosted
                ? [AppColors.neonRose.withValues(alpha: 0.3), AppColors.neonRose.withValues(alpha: 0.15)]
                : [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isBoosted
                ? AppColors.neonRose.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: isBoosted
                  ? AppColors.neonRose
                  : Colors.white.withValues(alpha: 0.7),
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
