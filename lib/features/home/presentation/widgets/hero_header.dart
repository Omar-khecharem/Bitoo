import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class HeroHeader extends StatefulWidget {
  const HeroHeader({super.key, required this.scrollOffset});

  final double scrollOffset;

  @override
  State<HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<HeroHeader>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCollapsed = widget.scrollOffset > 200;

    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        final t = _gradientController.value;
        final primary = Color.lerp(
          AppColors.primary600,
          AppColors.tertiary500,
          (sin(t * pi * 2) + 1) / 2,
        );
        final secondary = Color.lerp(
          AppColors.tertiary500,
          AppColors.secondary500,
          (sin(t * pi * 2 + 0.3) + 1) / 2,
        );

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary!,
                secondary!,
                AppColors.darkBackground,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.4, 0.8],
            ),
          ),
          child: Stack(
            children: [
              // Particle overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlePainter(time: t),
                ),
              ),

              // Glass fade at bottom
              Positioned(
                left: 0, right: 0, bottom: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.darkBackground.withValues(alpha: 0.6),
                        AppColors.darkBackground,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Content
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Spacing.pageHorizontal,
                    Spacing.lg,
                    Spacing.pageHorizontal,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: greeting + avatar
                      _buildTopRow(isCollapsed),
                      SizedBox(height: isCollapsed ? 8 : Spacing.xl),

                      // Search bar (collapses on scroll)
                      if (!isCollapsed) ...[
                        _buildSearchBar(),
                        SizedBox(height: Spacing.xl),
                      ],

                      // Quick actions (collapses on scroll)
                      if (!isCollapsed) _buildQuickActions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopRow(bool isCollapsed) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: isCollapsed
                    ? AppTypography.headlineMedium
                    : AppTypography.displayMedium.copyWith(
                        color: AppColors.darkTextPrimary,
                      ),
              ),
              if (isCollapsed)
                Text(
                  'Home',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
            ],
          ),
        ),
        // User avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Container(
              color: AppColors.primary500.withValues(alpha: 0.3),
              child: Icon(Icons.person_rounded, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
            border: Border.all(
              color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              SizedBox(width: Spacing.lg),
              Icon(Icons.search_rounded, size: 20, color: AppColors.darkTextSecondary),
              SizedBox(width: Spacing.md),
              Text(
                'What do you want to listen to?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            _quickActionChip(Icons.shuffle_rounded, 'Smart Shuffle', AppColors.primary500, 0),
            _quickActionChip(Icons.history_rounded, 'Recent', AppColors.tertiary500, 1),
            _quickActionChip(Icons.favorite_rounded, 'Favorites', AppColors.secondary500, 2),
            _quickActionChip(Icons.download_rounded, 'Downloads', AppColors.success, 3),
            _quickActionChip(Icons.settings_rounded, 'Settings', AppColors.info, 4),
          ].asMap().entries.map((entry) {
            final delay = entry.key * 0.05;
            final animValue = ((_staggerController.value - delay) / 0.3).clamp(0.0, 1.0);
            return Opacity(
              opacity: animValue,
              child: Transform.scale(
                scale: 0.5 + 0.5 * animValue,
                child: entry.value,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _quickActionChip(IconData icon, String label, Color color, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: Spacing.xs),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.time});
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(time.toInt());
    for (var i = 0; i < 12; i++) {
      final x = (rng.nextDouble() * size.width + time * 20 * (i % 2 == 0 ? 1 : -1)) % size.width;
      final y = (rng.nextDouble() * size.height + time * 10 * (i % 2 == 0 ? 1 : -1)) % size.height;
      final opacity = (sin(time * pi + i) + 1) / 2 * 0.15;
      canvas.drawCircle(
        Offset(x, y),
        1.5 + sin(time + i) * 0.5,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.time != time;
}
