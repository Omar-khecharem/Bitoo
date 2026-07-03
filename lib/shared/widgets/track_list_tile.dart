import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/tokens.dart';

class TrackListTile extends StatelessWidget {
  const TrackListTile({
    super.key,
    this.rank,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.imageUrl,
    this.isActive = false,
    this.onTap,
    this.onMenuTap,
  });

  final int? rank;
  final String title;
  final String subtitle;
  final String? trailing;
  final String? imageUrl;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: Spacing.pageHorizontal),
        child: Row(
          children: [
            if (rank != null)
              SizedBox(
                width: 32,
                child: Text(
                  '$rank',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isActive ? AppColors.primary500 : AppColors.darkTextTertiary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.network(
                  imageUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    color: AppColors.darkSurfaceLight,
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 18,
                      color: AppColors.darkTextTertiary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Spacing.md),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: isActive ? AppColors.primary500 : AppColors.darkTextPrimary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.darkTextTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextTertiary,
                ),
              ),
            if (onMenuTap != null) ...[
              SizedBox(width: Spacing.sm),
              GestureDetector(
                onTap: onMenuTap,
                child: Padding(
                  padding: EdgeInsets.all(Spacing.xs),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: AppIconSizes.small,
                    color: AppColors.darkTextTertiary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    this.trackTitle,
    this.artistName,
    this.imageUrl,
    this.isPlaying = false,
    this.progress = 0.0,
    this.onPlayPause,
    this.onTap,
  });

  final String? trackTitle;
  final String? artistName;
  final String? imageUrl;
  final bool isPlaying;
  final double progress;
  final VoidCallback? onPlayPause;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: AppColors.glassOpacityStrong),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
              width: 0.5,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Image.network(
                            imageUrl ?? '',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 40,
                              height: 40,
                              color: AppColors.darkSurfaceLight,
                              child: Icon(
                                Icons.music_note_rounded,
                                size: 18,
                                color: AppColors.darkTextTertiary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Spacing.md),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trackTitle ?? 'No track playing',
                                style: AppTypography.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                artistName ?? '',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.darkTextTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: Spacing.sm),
                        GestureDetector(
                          onTap: onPlayPause,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.darkTextPrimary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
