import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

class CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  final String id;

  const CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.id,
  });
}

class PremiumCategoryBar extends StatefulWidget {
  final List<CategoryItem> categories;
  final String? selectedId;
  final ValueChanged<String> onCategoryTap;
  final ScrollPhysics? physics;

  const PremiumCategoryBar({
    super.key,
    required this.categories,
    this.selectedId,
    required this.onCategoryTap,
    this.physics,
  });

  @override
  State<PremiumCategoryBar> createState() => _PremiumCategoryBarState();
}

class _PremiumCategoryBarState extends State<PremiumCategoryBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(PremiumCategoryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    if (widget.selectedId == null) return;
    final selectedIndex =
        widget.categories.indexWhere((c) => c.id == widget.selectedId);
    if (selectedIndex < 0) return;
    final offset = selectedIndex * 90.0 - 20;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: AppDurations.standard,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: widget.physics ?? const BouncingScrollPhysics(),
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = widget.categories[i];
          final isSelected = cat.id == widget.selectedId;
          return GestureDetector(
            onTap: () => widget.onCategoryTap(cat.id),
            child: AnimatedContainer(
              duration: AppDurations.standard,
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          cat.color.withValues(alpha: 0.25),
                          cat.color.withValues(alpha: 0.1)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? cat.color.withValues(alpha: 0.4)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: AppDurations.standard,
                    child: Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected
                          ? cat.color
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? cat.color
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
