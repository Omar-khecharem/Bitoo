import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class EqualizerWidget extends StatefulWidget {
  const EqualizerWidget({
    super.key,
    required this.bands,
    this.onBandChanged,
    this.activePreset,
    this.onPresetChanged,
    this.isEnabled = true,
  });

  final List<double> bands;
  final void Function(int index, double value)? onBandChanged;
  final String? activePreset;
  final void Function(String preset)? onPresetChanged;
  final bool isEnabled;

  @override
  State<EqualizerWidget> createState() => _EqualizerWidgetState();
}

class _EqualizerWidgetState extends State<EqualizerWidget> {
  static const _frequencies = ['31', '63', '125', '250', '500', '1k', '2k', '4k', '8k', '16k'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Presets row
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                'Custom', 'Pop', 'Rock', 'Jazz', 'Classical', 'Dance', 'Acoustic', 'Bass',
              ].map((preset) {
                final isActive = preset == (widget.activePreset ?? 'Custom');
                return Padding(
                  padding: EdgeInsets.only(right: Spacing.sm),
                  child: GestureDetector(
                    onTap: () => widget.onPresetChanged?.call(preset),
                    child: AnimatedContainer(
                      duration: AppDurations.standard,
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.lg,
                        vertical: Spacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary500.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary500.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        preset,
                        style: AppTypography.labelSmall.copyWith(
                          color: isActive ? AppColors.primary500 : AppColors.darkTextSecondary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: Spacing.xl),

          // Equalizer sliders
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _EQGridPainter(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(widget.bands.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < widget.bands.length - 1 ? 2 : 0),
                      child: _EQSlider(
                        value: widget.bands[i],
                        label: _frequencies[i],
                        isEnabled: widget.isEnabled,
                        onChanged: (v) => widget.onBandChanged?.call(i, v),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          SizedBox(height: Spacing.md),

          // Frequency labels
          Row(
            children: _frequencies.map((f) => Expanded(
              child: Text(
                f,
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.darkTextTertiary,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _EQSlider extends StatefulWidget {
  const _EQSlider({
    required this.value,
    required this.label,
    required this.isEnabled,
    required this.onChanged,
  });

  final double value;
  final String label;
  final bool isEnabled;
  final ValueChanged<double> onChanged;

  @override
  State<_EQSlider> createState() => _EQSliderState();
}

class _EQSliderState extends State<_EQSlider> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            final height = constraints.maxHeight;
            final normalized = 1.0 - (details.localPosition.dy / height);
            widget.onChanged(normalized.clamp(0.0, 1.0) * 2 - 1);
          },
          child: CustomPaint(
            painter: _EQBarPainter(
              value: widget.value,
              isEnabled: widget.isEnabled,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        );
      },
    );
  }
}

class _EQGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    // Horizontal center line (0dB)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..strokeWidth = 1,
    );

    // Horizontal grid lines
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EQBarPainter extends CustomPainter {
  _EQBarPainter({required this.value, required this.isEnabled});

  final double value;
  final bool isEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final barHeight = size.height * 0.9 * (value.abs() / 1.0);
    final barWidth = size.width * 0.7;
    final x = (size.width - barWidth) / 2;

    final isPositive = value >= 0;
    final y = isPositive ? centerY - barHeight : centerY;

    final color = isEnabled
        ? (isPositive
            ? AppColors.primary500
            : AppColors.tertiary500)
        : AppColors.darkTextTertiary;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, barWidth, barHeight),
      Radius.circular(barWidth / 2),
    );

    canvas.drawRRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: isPositive ? Alignment.bottomCenter : Alignment.topCenter,
          end: isPositive ? Alignment.topCenter : Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.3),
            color,
          ],
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight)),
    );

    // Center dot
    canvas.drawCircle(
      Offset(size.width / 2, y),
      3,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _EQBarPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.isEnabled != isEnabled;
}

class AudioEffectsPanel extends StatefulWidget {
  const AudioEffectsPanel({
    super.key,
    this.onClose,
  });

  final VoidCallback? onClose;

  @override
  State<AudioEffectsPanel> createState() => _AudioEffectsPanelState();
}

class _AudioEffectsPanelState extends State<AudioEffectsPanel> {
  double _bass = 0.0;
  double _virtualizer = 0.5;
  double _crossfade = 3.0;
  bool _fadeIn = false;
  bool _fadeOut = false;
  bool _eqEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          // Handle
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

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(Spacing.xl, Spacing.lg, Spacing.md, Spacing.sm),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, size: AppIconSizes.small, color: AppColors.darkTextPrimary),
                SizedBox(width: Spacing.sm),
                Text('Audio Effects', style: AppTypography.titleLarge),
                Spacer(),
                GestureDetector(
                  onTap: widget.onClose,
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

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Spacing.lg),
              child: Column(
                children: [
                  // Equalizer toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Equalizer', style: AppTypography.titleMedium),
                      Switch(
                        value: _eqEnabled,
                        onChanged: (v) => setState(() => _eqEnabled = v),
                      ),
                    ],
                  ),
                  if (_eqEnabled)
                    EqualizerWidget(
                      bands: List.filled(10, 0.0),
                      isEnabled: _eqEnabled,
                    ),

                  SizedBox(height: Spacing.xl),

                  // Bass
                  _EffectSlider(
                    icon: Icons.music_note_rounded,
                    label: 'Bass Boost',
                    value: _bass,
                    min: -12,
                    max: 12,
                    suffix: 'dB',
                    onChanged: (v) => setState(() => _bass = v),
                  ),

                  SizedBox(height: Spacing.lg),

                  // Virtualizer
                  _EffectSlider(
                    icon: Icons.surround_sound_rounded,
                    label: 'Virtualizer (3D Audio)',
                    value: _virtualizer,
                    min: 0,
                    max: 100,
                    suffix: '%',
                    formatValue: (v) => '${v.round()}',
                    onChanged: (v) => setState(() => _virtualizer = v),
                  ),

                  SizedBox(height: Spacing.lg),

                  // Crossfade
                  _EffectSlider(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Crossfade',
                    value: _crossfade,
                    min: 0,
                    max: 12,
                    suffix: 's',
                    onChanged: (v) => setState(() => _crossfade = v),
                  ),

                  SizedBox(height: Spacing.lg),

                  // Fade in/out
                  Row(
                    children: [
                      Expanded(
                        child: _ToggleTile(
                          icon: Icons.trending_up_rounded,
                          label: 'Fade In',
                          value: _fadeIn,
                          onChanged: (v) => setState(() => _fadeIn = v),
                        ),
                      ),
                      SizedBox(width: Spacing.md),
                      Expanded(
                        child: _ToggleTile(
                          icon: Icons.trending_down_rounded,
                          label: 'Fade Out',
                          value: _fadeOut,
                          onChanged: (v) => setState(() => _fadeOut = v),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Spacing.xxl),

                  // Reset
                  Center(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.restart_alt_rounded, size: 18),
                      label: Text('Reset to Default'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EffectSlider extends StatelessWidget {
  const _EffectSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.suffix = '',
    this.formatValue,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final String Function(double)? formatValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalized = (value - min) / (max - min);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: AppIconSizes.small, color: AppColors.darkTextSecondary),
            SizedBox(width: Spacing.sm),
            Text(label, style: AppTypography.titleSmall),
            Spacer(),
            Text(
              '${formatValue?.call(value) ?? value.toStringAsFixed(1)}$suffix',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
            ),
          ],
        ),
        SizedBox(height: Spacing.sm),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary500,
            inactiveTrackColor: AppColors.darkTextTertiary.withValues(alpha: 0.15),
            trackHeight: 3,
            thumbColor: AppColors.primary500,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayColor: AppColors.primary500.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: normalized.clamp(0.0, 1.0),
            onChanged: (v) => onChanged(min + v * (max - min)),
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: AppDurations.standard,
        padding: EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary500.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
          border: Border.all(
            color: value
                ? AppColors.primary500.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppIconSizes.medium,
              color: value ? AppColors.primary500 : AppColors.darkTextTertiary,
            ),
            SizedBox(height: Spacing.sm),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: value ? AppColors.primary500 : AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
