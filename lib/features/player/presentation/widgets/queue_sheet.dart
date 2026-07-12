import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class QueueSheet extends StatefulWidget {
  const QueueSheet({
    super.key,
    required this.tracks,
    this.currentIndex,
    this.onReorder,
    this.onRemove,
    this.onTapTrack,
    this.onClear,
  });

  final List<QueueItemData> tracks;
  final int? currentIndex;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final void Function(int index)? onRemove;
  final void Function(int index)? onTapTrack;
  final VoidCallback? onClear;

  @override
  State<QueueSheet> createState() => _QueueSheetState();
}

class _QueueSheetState extends State<QueueSheet> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.only(top: Spacing.md),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.xl,
                Spacing.lg,
                Spacing.md,
                Spacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    size: AppIconSizes.small,
                    color: AppColors.darkTextPrimary,
                  ),
                  SizedBox(width: Spacing.sm),
                  Text(
                    'Queue',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  SizedBox(width: Spacing.sm),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: AppColors.glassOpacityMedium),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${widget.tracks.length}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: widget.onClear,
                    child: Text(
                      'Clear',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.darkTextTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              color: Colors.white.withValues(alpha: 0.06),
              height: 1,
            ),

            // Queue list
            Expanded(
              child: widget.tracks.isEmpty
                  ? _EmptyQueue()
                  : ReorderableListView.builder(
                      padding: EdgeInsets.only(top: Spacing.sm),
                      itemCount: widget.tracks.length,
                      onReorder: widget.onReorder ?? (_, __) {},
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return Material(
                              color: Colors.transparent,
                              elevation: 4,
                              child: Transform.scale(
                                scale: 1.03,
                                child: child,
                              ),
                            );
                          },
                          child: child,
                        );
                      },
                      itemBuilder: (context, index) {
                        final track = widget.tracks[index];
                        final isCurrent = index == widget.currentIndex;

                        return Dismissible(
                          key: ValueKey(track.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: Spacing.xl),
                            color: AppColors.error.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                              size: AppIconSizes.medium,
                            ),
                          ),
                          onDismissed: (_) => widget.onRemove?.call(index),
                          child: _QueueItem(
                            track: track,
                            isCurrent: isCurrent,
                            onTap: () => widget.onTapTrack?.call(index),
                          ),
                        );
                      },
                    ),
            ),

            // Suggested tracks
            if (widget.tracks.isNotEmpty) ...[
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
              Container(
                height: 120,
                padding: EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggestions',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    SizedBox(height: Spacing.sm),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                            5,
                            (i) => Container(
                                  width: 100,
                                  margin: EdgeInsets.only(right: Spacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkSurfaceLight,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Track $i',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.darkTextTertiary,
                                      ),
                                    ),
                                  ),
                                )),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  const _QueueItem({
    required this.track,
    required this.isCurrent,
    this.onTap,
  });

  final QueueItemData track;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
        color: isCurrent
            ? AppColors.primary500.withValues(alpha: 0.05)
            : Colors.transparent,
        child: Row(
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.only(right: Spacing.md),
              child: Icon(
                Icons.drag_handle_rounded,
                size: 20,
                color: AppColors.darkTextTertiary.withValues(alpha: 0.5),
              ),
            ),

            // Album art
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: Container(
                width: 40,
                height: 40,
                color: AppColors.darkSurfaceLight,
                child: Icon(
                  Icons.music_note_rounded,
                  size: 16,
                  color: AppColors.darkTextTertiary,
                ),
              ),
            ),
            SizedBox(width: Spacing.md),

            // Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: isCurrent
                          ? AppColors.primary500
                          : AppColors.darkTextPrimary,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    track.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.darkTextTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Duration
            Text(
              track.duration,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.queue_play_next_rounded,
              size: 28,
              color: AppColors.darkTextTertiary,
            ),
          ),
          SizedBox(height: Spacing.lg),
          Text(
            'Queue is empty',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          SizedBox(height: Spacing.sm),
          Text(
            'Add tracks from your library',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class QueueItemData {
  final String id;
  final String title;
  final String subtitle;
  final String duration;
  final String? imageUrl;

  const QueueItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    this.imageUrl,
  });
}
