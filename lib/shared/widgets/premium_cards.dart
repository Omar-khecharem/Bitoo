import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/tokens.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onPlay,
    this.aspectRatio = 1,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: AppDurations.standard,
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                Icons.music_note_rounded,
                                size: 40,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: Spacing.sm,
                        bottom: Spacing.sm,
                        child: GestureDetector(
                          onTap: onPlay,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: AppGradients.blueToIndigo,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonIndigo.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: Spacing.sm),
                  child: Text(
                    title,
                    style: AppTypography.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.darkTextTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class ArtistCard extends StatelessWidget {
  const ArtistCard({
    super.key,
    required this.imageUrl,
    required this.name,
    this.subtitle,
    this.onTap,
    this.imageSize = 120,
  });

  final String imageUrl;
  final String name;
  final String? subtitle;
  final VoidCallback? onTap;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                width: 2,
              ),
              boxShadow: AppShadows.shadowSM,
            ),
            child: ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.darkSurfaceLight,
                  child: Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: Spacing.sm),
          Text(
            name,
            style: AppTypography.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkTextTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.trackCount,
    this.onTap,
    this.onPlay,
  });

  final String imageUrl;
  final String title;
  final String? trackCount;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.neonIndigo.withValues(alpha: 0.5),
                        AppColors.neonBlue.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (trackCount != null) ...[
                      SizedBox(height: 2),
                      Text(
                        trackCount!,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onPlay != null)
                Positioned(
                  right: Spacing.sm,
                  top: Spacing.sm,
                  child: GestureDetector(
                    onTap: onPlay,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: AppColors.glassOpacityStrong),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
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
