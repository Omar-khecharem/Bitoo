import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class SleepTimerSheet extends StatefulWidget {
  const SleepTimerSheet({super.key});

  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet>
    with SingleTickerProviderStateMixin {
  int? _selectedMinutes;
  bool _stopAfterTrack = false;

  static const _presets = [5, 10, 15, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: Spacing.md),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(Spacing.xl, Spacing.lg, Spacing.md, Spacing.sm),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: AppIconSizes.small, color: AppColors.darkTextPrimary),
                SizedBox(width: Spacing.sm),
                Text('Sleep Timer', style: AppTypography.titleLarge),
                Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 18, color: AppColors.darkTextSecondary),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06)),

          // Circular timer display (shown when active)
          if (_selectedMinutes != null)
            Padding(
              padding: EdgeInsets.all(Spacing.xl),
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 6,
                      backgroundColor: AppColors.darkSurfaceLight,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary500),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_selectedMinutes:00',
                            style: AppTypography.displayMedium.copyWith(
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          Text(
                            'remaining',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.darkTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Preset buttons
          Padding(
            padding: EdgeInsets.fromLTRB(Spacing.xl, 0, Spacing.xl, Spacing.lg),
            child: Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: _presets.map((minutes) {
                final isSelected = _selectedMinutes == minutes;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMinutes = minutes),
                  child: AnimatedContainer(
                    duration: AppDurations.standard,
                    padding: EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.md),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary500.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary500.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      '${minutes}m',
                      style: AppTypography.titleMedium.copyWith(
                        color: isSelected ? AppColors.primary500 : AppColors.darkTextPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Stop after track option
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.xl),
            child: Row(
              children: [
                Icon(Icons.music_note_rounded, size: AppIconSizes.small, color: AppColors.darkTextSecondary),
                SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    'Stop after current track',
                    style: AppTypography.titleSmall.copyWith(color: AppColors.darkTextSecondary),
                  ),
                ),
                Switch(
                  value: _stopAfterTrack,
                  onChanged: (v) => setState(() => _stopAfterTrack = v),
                ),
              ],
            ),
          ),

          // Fade out option
          Padding(
            padding: EdgeInsets.fromLTRB(Spacing.xl, 0, Spacing.xl, Spacing.xl),
            child: Row(
              children: [
                Icon(Icons.trending_down_rounded, size: AppIconSizes.small, color: AppColors.darkTextSecondary),
                SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    'Fade out over last 30 seconds',
                    style: AppTypography.titleSmall.copyWith(color: AppColors.darkTextSecondary),
                  ),
                ),
                Switch(
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),

          // Start button
          if (_selectedMinutes != null)
            Padding(
              padding: EdgeInsets.fromLTRB(Spacing.xl, 0, Spacing.xl, Spacing.xl),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Center(
                  child: Text(
                    'Start Timer',
                    style: AppTypography.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + Spacing.md),
        ],
      ),
    );
  }
}
