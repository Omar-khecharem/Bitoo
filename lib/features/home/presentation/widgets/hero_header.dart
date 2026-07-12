import 'package:flutter/material.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/premium_search_bar.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.scrollOffset,
    this.searchController,
    this.onSearchChanged,
    this.onFilterTap,
    this.onSettingsTap,
  });

  final double scrollOffset;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final isCollapsed = scrollOffset > 200;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            cs.secondary,
            isDark ? cs.surface : cs.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.4, 0.8],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    cs.surface.withValues(alpha: isDark ? 0.6 : 0.8),
                    cs.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopRow(isCollapsed, context),
                  SizedBox(height: isCollapsed ? 8 : Spacing.xl),
                  if (!isCollapsed) ...[
                    _buildSearchBar(context),
                    SizedBox(height: Spacing.xl),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow(bool isCollapsed, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/app_icon.png',
            width: isCollapsed ? 36 : 52,
            height: isCollapsed ? 36 : 52,
            errorBuilder: (_, __, ___) => Container(
              width: isCollapsed ? 36 : 52,
              height: isCollapsed ? 36 : 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary.withValues(alpha: 0.7), cs.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.music_note_rounded,
                  color: cs.onPrimary, size: isCollapsed ? 18 : 26),
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.onSurface.withValues(alpha: 0.06),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1.0,
              ),
            ),
            child: Icon(Icons.filter_list_rounded,
                size: 20, color: cs.onSurface.withValues(alpha: 0.6)),
          ),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: onSettingsTap ??
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  ),
                );
              },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.onSurface.withValues(alpha: 0.06),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1.0,
              ),
            ),
            child: Icon(Icons.tune_rounded,
                size: 20, color: cs.onSurface.withValues(alpha: 0.6)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return PremiumSearchBar(
      hintText: 'Artistes, chansons, albums...',
      large: false,
      controller: searchController,
      onChanged: onSearchChanged,
    );
  }
}
