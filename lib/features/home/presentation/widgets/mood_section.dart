import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class MoodSection extends StatelessWidget {
  const MoodSection({
    super.key,
    required this.moods,
    this.onMoodTap,
  });

  final List<Mood> moods;
  final void Function(Mood)? onMoodTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        padding: EdgeInsets.only(right: Spacing.pageHorizontal),
        itemBuilder: (context, index) {
          final mood = moods[index];
          final isFirst = index == 0;
          return Padding(
            padding: EdgeInsets.only(
              left: isFirst ? 0 : Spacing.md,
            ),
            child: GestureDetector(
              onTap: () => onMoodTap?.call(mood),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          mood.color.withValues(alpha: 0.6),
                          mood.color.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: mood.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(44),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Center(
                          child: Icon(
                            mood.icon,
                            size: 32,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Spacing.sm),
                  Text(
                    mood.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Mood {
  final String label;
  final IconData icon;
  final Color color;

  const Mood(this.label, this.icon, this.color);
}
