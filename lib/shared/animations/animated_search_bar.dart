import 'package:flutter/material.dart';
import '../../core/animations/curves.dart';
import '../../core/theme/tokens.dart';
import 'micro_animations.dart';
import 'animated_list_item.dart';

class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onBack;
  final bool autoFocus;

  const AnimatedSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onClear,
    this.onBack,
    this.autoFocus = false,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _widthFactor;
  late Animation<double> _iconOpacity;
  late Animation<double> _backOpacity;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _widthFactor = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: AnimationCurves.premiumEase),
    );
    _iconOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _expandController, curve: AnimationCurves.premiumEase),
    );
    _backOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: AnimationCurves.premiumEaseOut),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
      widget.focusNode?.requestFocus();
    } else {
      _expandController.reverse();
      widget.focusNode?.unfocus();
      widget.controller.clear();
      widget.onClear?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 44,
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C26),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _backOpacity,
              builder: (context, child) => Opacity(
                opacity: _backOpacity.value,
                child: child,
              ),
              child: ScaleOnTap(
                onTap: _isExpanded ? _toggleExpand : null,
                child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _iconOpacity,
              builder: (context, child) => Opacity(
                opacity: _iconOpacity.value,
                child: child,
              ),
              child: ScaleOnTap(
                onTap: _isExpanded ? null : _toggleExpand,
                child: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _widthFactor,
                builder: (context, child) => ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _widthFactor.value,
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    onChanged: widget.onChanged,
                    autofocus: widget.autoFocus,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search songs, artists, albums...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    cursorColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ),
            if (_isExpanded)
              ScaleOnTap(
                onTap: () {
                  widget.controller.clear();
                  widget.onClear?.call();
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: AnimatedListInsert(
                    isVisible: widget.controller.text.isNotEmpty,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AnimatedFilterChips extends StatefulWidget {
  final List<String> labels;
  final String selected;
  final ValueChanged<String>? onSelected;

  const AnimatedFilterChips({
    super.key,
    required this.labels,
    required this.selected,
    this.onSelected,
  });

  @override
  State<AnimatedFilterChips> createState() => _AnimatedFilterChipsState();
}

class _AnimatedFilterChipsState extends State<AnimatedFilterChips>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
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
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: widget.labels.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isSelected = label == widget.selected;

            return _AnimatedChip(
              index: index,
              label: label,
              isSelected: isSelected,
              onTap: () => widget.onSelected?.call(label),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AnimatedChip extends StatefulWidget {
  final int index;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _AnimatedChip({
    required this.index,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<_AnimatedChip> createState() => _AnimatedChipState();
}

class _AnimatedChipState extends State<_AnimatedChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _slide = Tween<Offset>(
      begin: Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.premiumEaseOut,
    ));
    Future.delayed(Duration(milliseconds: 30 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Padding(
        padding: EdgeInsets.only(right: 8),
        child: ScaleOnTap(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: AnimationCurves.premiumEase,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: widget.isSelected
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.06),
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedSearchResults extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const AnimatedSearchResults({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8),
        itemCount: itemCount,
        itemBuilder: (context, index) => _SearchResultItem(
          index: index,
          child: itemBuilder(context, index),
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _SearchResultItem({
    required this.index,
    required this.child,
  });

  @override
  State<_SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<_SearchResultItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.premiumEaseOut),
    );
    _slide = Tween<Offset>(
      begin: Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.premiumEaseOut,
    ));
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
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
