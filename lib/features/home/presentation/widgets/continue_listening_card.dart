import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class ContinueListeningCard extends StatelessWidget {
  const ContinueListeningCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.progress = 0.0,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String? imageUrl;
  final VoidCallback? onTap;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album art
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonIndigo.withValues(alpha: 0.15),
                      AppColors.neonRose.withValues(alpha: 0.15),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.music_note_rounded,
                    size: 36,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),

            // Info
            Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.darkTextTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Spacing.sm),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      height: 3,
                      child: Row(
                        children: [
                          Expanded(
                            flex: (progress * 100).round(),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 100 - (progress * 100).round(),
                            child: Container(
                              color: AppColors.darkTextTertiary
                                  .withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
