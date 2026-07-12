import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';

class PremiumBottomSheet extends StatelessWidget {
  final Widget child;
  final double? maxHeight;
  final bool showDragHandle;

  const PremiumBottomSheet({
    super.key,
    required this.child,
    this.maxHeight,
    this.showDragHandle = true,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget builder,
    double? maxHeight,
    bool showDragHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PremiumBottomSheet(
        maxHeight: maxHeight,
        showDragHandle: showDragHandle,
        child: builder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(8, 0, 8, bottom + 8),
      constraints:
          maxHeight != null ? BoxConstraints(maxHeight: maxHeight!) : null,
      decoration: BoxDecoration(
        color: isDark ? cs.surface : cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 2),
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class PremiumActionSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PremiumActionSheetTile({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (color ?? AppColors.neonIndigo).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color ?? AppColors.neonIndigo),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class PremiumConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final IconData? icon;
  final VoidCallback onConfirm;

  const PremiumConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    this.icon,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => PremiumConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        icon: icon,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? cs.surface : cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (confirmColor ?? AppColors.neonRose)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 28, color: confirmColor ?? AppColors.neonRose),
            ),
            SizedBox(height: 16),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.onSurface.withValues(alpha: 0.6),
              side: BorderSide(color: cs.onSurface.withValues(alpha: 0.12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(cancelLabel,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.6))),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              foregroundColor: cs.onPrimary,
              backgroundColor: confirmColor ?? cs.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(confirmLabel,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class PremiumInputDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String confirmLabel;
  final String? initialValue;
  final ValueChanged<String> onConfirm;

  const PremiumInputDialog({
    super.key,
    required this.title,
    required this.hintText,
    this.confirmLabel = 'Create',
    this.initialValue,
    required this.onConfirm,
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String hintText,
    String confirmLabel = 'Create',
    String? initialValue,
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => PremiumInputDialog(
        title: title,
        hintText: hintText,
        confirmLabel: confirmLabel,
        initialValue: initialValue,
        onConfirm: (v) => Navigator.of(context).pop(v),
      ),
    );
  }

  @override
  State<PremiumInputDialog> createState() => _PremiumInputDialogState();
}

class _PremiumInputDialogState extends State<PremiumInputDialog> {
  late TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _isValid = _controller.text.trim().isNotEmpty;
    _controller.addListener(() {
      setState(() => _isValid = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? cs.surface : cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(color: cs.onSurface, fontSize: 16),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    TextStyle(color: cs.onSurface.withValues(alpha: 0.3)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isValid
                ? () => widget.onConfirm(_controller.text.trim())
                : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: cs.onPrimary,
              backgroundColor:
                  _isValid ? cs.primary : cs.onSurface.withValues(alpha: 0.06),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(widget.confirmLabel,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
