import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/tokens.dart';
import 'premium_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  factory EmptyState.library({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.library_music_outlined,
      title: 'Your library is quiet',
      description: 'Add your first track to get started',
      actionLabel: 'Browse Music',
      onAction: onAction,
    );
  }

  factory EmptyState.search() {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'No results found',
      description: 'Try a different search term',
    );
  }

  factory EmptyState.playlist({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.queue_music_rounded,
      title: 'Curate your first playlist',
      description: 'Group your favorite tracks together',
      actionLabel: 'Create Playlist',
      onAction: onAction,
    );
  }

  factory EmptyState.downloads({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.download_outlined,
      title: 'No downloads yet',
      description: 'Download music for offline playback',
      actionLabel: 'Find Music',
      onAction: onAction,
    );
  }

  factory EmptyState.queue() {
    return EmptyState(
      icon: Icons.queue_play_next_rounded,
      title: 'Queue is empty',
      description: 'Add tracks from your library',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Spacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: AppColors.glassOpacityMedium),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.darkTextTertiary,
              ),
            ),
            SizedBox(height: Spacing.xl),
            Text(
              title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: Spacing.sm),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: Spacing.xl),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                size: ButtonSize.md,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.icon,
    this.title = 'Something went wrong',
    this.description,
    this.onRetry,
    this.isOffline = false,
  });

  final IconData? icon;
  final String title;
  final String? description;
  final VoidCallback? onRetry;
  final bool isOffline;

  factory ErrorState.offline({VoidCallback? onRetry}) {
    return ErrorState(
      icon: Icons.wifi_off_rounded,
      title: "You're offline",
      description: 'Play from your downloads or connect to the internet',
      isOffline: true,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Spacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: Spacing.xl),
            Text(
              title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: Spacing.sm),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: Spacing.xl),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: 'Try Again',
                    onPressed: onRetry,
                    size: ButtonSize.md,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
