import 'package:flutter/material.dart';
import '../../core/animations/curves.dart';
import '../../core/theme/tokens.dart';

class StaggeredList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Duration baseDelay;

  const StaggeredList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.baseDelay = AppDurations.staggerItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => _StaggeredItem(
          index: index,
          baseDelay: baseDelay,
          child: itemBuilder(context, index),
        ),
      ),
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  final int index;
  final Duration baseDelay;
  final Widget child;

  const _StaggeredItem({
    required this.index,
    required this.baseDelay,
    required this.child,
  });

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );

    _slide = Tween<Offset>(
      begin: Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.premiumEaseOut,
    ));

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationCurves.premiumEaseOut,
      ),
    );

    Future.delayed(widget.baseDelay * widget.index, () {
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

class AnimatedListInsert extends StatefulWidget {
  final Widget child;
  final bool isVisible;

  const AnimatedListInsert({
    super.key,
    required this.child,
    required this.isVisible,
  });

  @override
  State<AnimatedListInsert> createState() => _AnimatedListInsertState();
}

class _AnimatedListInsertState extends State<AnimatedListInsert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.premiumEase),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: AnimationCurves.premiumEaseOut),
    );
    if (widget.isVisible) _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedListInsert oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _fade.value,
          child: Transform.scale(scale: _scale.value, child: child),
        ),
        child: widget.child,
      ),
    );
  }
}

class AnimatedListRemove extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  const AnimatedListRemove({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<AnimatedListRemove> createState() => _AnimatedListRemoveState();
}

class _AnimatedListRemoveState extends State<AnimatedListRemove> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - widget.controller.value,
            child: Transform.scale(
              scale: 1.0 - (widget.controller.value * 0.3),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class ReorderableDragHandle extends StatelessWidget {
  final bool isDragging;

  const ReorderableDragHandle({
    super.key,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: AnimationCurves.premiumEase,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isDragging
            ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.drag_indicator_rounded,
        size: 20,
        color: Colors.white.withValues(alpha: isDragging ? 0.8 : 0.3),
      ),
    );
  }
}

class AnimatedSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const AnimatedSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.isExpanded = true,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onToggle,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              if (actionLabel != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      color: const Color(0xFF8B5CF6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (onToggle != null)
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.0 : 0.5,
                    duration: AppDurations.fast,
                    curve: AnimationCurves.premiumEase,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCollapsibleSection extends StatefulWidget {
  final Widget child;
  final bool isExpanded;

  const AnimatedCollapsibleSection({
    super.key,
    required this.child,
    required this.isExpanded,
  });

  @override
  State<AnimatedCollapsibleSection> createState() =>
      _AnimatedCollapsibleSectionState();
}

class _AnimatedCollapsibleSectionState extends State<AnimatedCollapsibleSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _height;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _height = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.premiumEase),
    );
    if (widget.isExpanded) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedCollapsibleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _controller.forward();
    } else if (!widget.isExpanded && oldWidget.isExpanded) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _height,
        builder: (context, child) => ClipRect(
          child: Align(
            heightFactor: _height.value,
            child: child,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
