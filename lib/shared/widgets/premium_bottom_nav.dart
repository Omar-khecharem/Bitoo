import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/tokens.dart';

class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            padding: EdgeInsets.only(top: Spacing.xs, bottom: Spacing.xs),
            decoration: BoxDecoration(
              color: const Color(0xCC1A1A1A),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
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

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppDurations.standard,
              curve: Curves.easeOut,
              width: isActive ? 40 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? AppColors.neonIndigo : Colors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            SizedBox(height: Spacing.xs),
            AnimatedSwitcher(
              duration: AppDurations.standard,
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: isActive ? AppIconSizes.large : AppIconSizes.medium,
                color: isActive ? AppColors.neonIndigo : AppColors.darkTextTertiary,
              ),
            ),
            SizedBox(height: 2),
            AnimatedOpacity(
              duration: AppDurations.standard,
              opacity: isActive ? 1.0 : 0.0,
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neonIndigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
