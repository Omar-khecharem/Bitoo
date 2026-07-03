import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/permission_constants.dart';
import '../../domain/entities/permission_state.dart';

class PermissionCard extends StatefulWidget {
  final String icon;
  final String title;
  final String description;
  final String grantLabel;
  final AppPermissionStatus status;
  final Future<AppPermissionStatus> Function() onRequest;
  final VoidCallback onOpenSettings;

  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.grantLabel,
    required this.status,
    required this.onRequest,
    required this.onOpenSettings,
  });

  factory PermissionCard.media({
    required AppPermissionStatus status,
    required Future<AppPermissionStatus> Function() onRequest,
    required VoidCallback onOpenSettings,
  }) {
    return PermissionCard(
      icon: PermissionLabels.media.icon,
      title: PermissionLabels.media.title,
      description: PermissionLabels.media.description,
      grantLabel: PermissionLabels.media.grantLabel,
      status: status,
      onRequest: onRequest,
      onOpenSettings: onOpenSettings,
    );
  }

  factory PermissionCard.notifications({
    required AppPermissionStatus status,
    required Future<AppPermissionStatus> Function() onRequest,
    required VoidCallback onOpenSettings,
  }) {
    return PermissionCard(
      icon: PermissionLabels.notifications.icon,
      title: PermissionLabels.notifications.title,
      description: PermissionLabels.notifications.description,
      grantLabel: PermissionLabels.notifications.grantLabel,
      status: status,
      onRequest: onRequest,
      onOpenSettings: onOpenSettings,
    );
  }

  factory PermissionCard.bluetooth({
    required AppPermissionStatus status,
    required Future<AppPermissionStatus> Function() onRequest,
    required VoidCallback onOpenSettings,
  }) {
    return PermissionCard(
      icon: PermissionLabels.bluetooth.icon,
      title: PermissionLabels.bluetooth.title,
      description: PermissionLabels.bluetooth.description,
      grantLabel: PermissionLabels.bluetooth.grantLabel,
      status: status,
      onRequest: onRequest,
      onOpenSettings: onOpenSettings,
    );
  }

  @override
  State<PermissionCard> createState() => _PermissionCardState();
}

class _PermissionCardState extends State<PermissionCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.03),
            ],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.2),
                            colorScheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.icon,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _StatusBadge(status: widget.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAction(context, colorScheme, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    if (widget.status is AppPermissionGranted) {
      return Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Granted',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (widget.status is AppPermissionPermanentlyDenied) {
      return SizedBox(
        width: double.infinity,
        child: _GlassButton(
          label: 'Open Settings',
          onPressed: _loading ? null : widget.onOpenSettings,
          loading: _loading,
          color: Colors.amber,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: _GlassButton(
              label: widget.grantLabel,
              onPressed: _loading ? null : _handleRequest,
              loading: _loading,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRequest() async {
    setState(() => _loading = true);
    try {
      await widget.onRequest();
    } catch (_) {
      // Permission request failed silently
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}

class _GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color color;

  const _GlassButton({
    required this.label,
    required this.onPressed,
    required this.loading,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AppPermissionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String icon;
    if (status is AppPermissionGranted) {
      color = Colors.green;
      icon = '✓';
    } else if (status is AppPermissionPermanentlyDenied) {
      color = Colors.amber;
      icon = '⚠';
    } else {
      color = Colors.white38;
      icon = '●';
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Center(
        child: Text(icon, style: TextStyle(color: color, fontSize: 12)),
      ),
    );
  }
}
