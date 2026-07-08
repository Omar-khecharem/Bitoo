import 'package:flutter/material.dart';

class PremiumSearchBar extends StatefulWidget {
  const PremiumSearchBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Artistes, chansons, albums...',
    this.controller,
    this.autofocus = false,
    this.onFilterTap,
    this.large = false,
  });

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final TextEditingController? controller;
  final bool autofocus;
  final VoidCallback? onFilterTap;
  final bool large;

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.large ? 58.0 : 54.0;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? cs.primary.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: _isFocused ? 20 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: _isFocused
                ? cs.surface.withValues(alpha: isDark ? 0.85 : 0.95)
                : cs.surface.withValues(alpha: isDark ? 0.75 : 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _isFocused
                  ? cs.primary.withValues(alpha: 0.3)
                  : cs.onSurface.withValues(alpha: isDark ? 0.06 : 0.1),
              width: 1.0,
            ),
          ),
          child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: cs.onSurface,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10, right: 6),
              child: Icon(
                Icons.search_rounded,
                size: 20,
                color: _isFocused
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.4),
              ),
            ),
            suffixIcon: widget.onFilterTap != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: widget.onFilterTap,
                      splashRadius: 16,
                    ),
                  )
                : widget.controller != null &&
                        widget.controller!.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                          onPressed: () {
                            widget.controller!.clear();
                            widget.onChanged?.call('');
                          },
                          splashRadius: 16,
                        ),
                      )
                    : null,
          ),
        ),
        ),
      ),
    );
  }
}
