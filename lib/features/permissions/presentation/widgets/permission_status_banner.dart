import 'package:flutter/material.dart';
import '../../domain/entities/permission_state.dart';

class PermissionStatusBanner extends StatelessWidget {
  final AllPermissionsState permissions;
  final VoidCallback onTap;

  const PermissionStatusBanner({
    super.key,
    required this.permissions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final missing = <String>[];
    if (permissions.media is! AppPermissionGranted) {
      missing.add('music access');
    }
    if (permissions.notifications is! AppPermissionGranted) {
      missing.add('notifications');
    }

    if (missing.isEmpty) return const SizedBox.shrink();

    final text = 'Enable ${missing.join(' and ')} in Settings';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.amber.withValues(alpha: 0.12),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_rounded,
              size: 20,
              color: Colors.amber.shade300,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.amber.shade200,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.amber.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
