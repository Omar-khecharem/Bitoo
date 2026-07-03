import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class GenreGrid extends StatelessWidget {
  const GenreGrid({
    super.key,
    required this.genres,
    this.onGenreTap,
  });

  final List<GenreData> genres;
  final void Function(GenreData)? onGenreTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Spacing.md,
        mainAxisSpacing: Spacing.md,
        childAspectRatio: 1.6,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        return GestureDetector(
          onTap: () => onGenreTap?.call(genre),
          child: Container(
            padding: EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  genre.color.withValues(alpha: 0.5),
                  genre.color.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: genre.color.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    genre.icon,
                    size: 18,
                    color: genre.color,
                  ),
                ),
                SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    genre.label,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.darkTextTertiary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GenreData {
  final String label;
  final Color color;
  final IconData icon;

  const GenreData(this.label, this.color, this.icon);
}
