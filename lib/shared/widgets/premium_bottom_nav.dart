import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.trackPath = '',
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String trackPath;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDark ? const Color(0xFF1A1210) : const Color(0xFFFFFBF5),
          ],
          stops: const [0.0, 0.15],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF2A2220) : const Color(0xFFFFFEFC))
                  .withValues(alpha: 0.85),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_tabs.length, (index) {
                final isActive = index == currentIndex;
                return _NavItem(
                  icon: _tabs[index].icon,
                  activeIcon: _tabs[index].activeIcon,
                  label: _tabs[index].label,
                  isActive: isActive,
                  onTap: () => onTap(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _springAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _springAnimation = CurvedAnimation(
      parent: _springController,
      curve: const _BounceOutCurve(),
    );
    if (widget.isActive) _springController.value = 1.0;
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _springController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: AnimatedBuilder(
          animation: _springAnimation,
          builder: (context, _) {
            final t = _springAnimation.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.isActive)
                      Container(
                        width: 32 + t * 8,
                        height: 32 + t * 8,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12 * t),
                          shape: BoxShape.circle,
                        ),
                      ),
                    Icon(
                      widget.isActive ? widget.activeIcon : widget.icon,
                      size: 22 + t * 2,
                      color: widget.isActive
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.45),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10 + t * 0.5,
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                    color: widget.isActive
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TabData {
  const _TabData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BounceOutCurve extends Curve {
  const _BounceOutCurve();

  @override
  double transformInternal(double t) {
    const overshoot = 1.1;
    const damping = 15.0;
    return 1.0 + (overshoot - 1.0) * (1.0 - _dampedOscillator(t * damping)) * (1.0 - t);
  }

  static double _dampedOscillator(double x) {
    return exp(-x * 0.5) * cos(x * 1.5 - 0.3);
  }
}

const _tabs = [
  _TabData(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
  ),
  _TabData(
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore,
    label: 'Explore',
  ),
  _TabData(
    icon: Icons.library_music_outlined,
    activeIcon: Icons.library_music,
    label: 'Library',
  ),
  _TabData(
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
    label: 'Search',
  ),
];
