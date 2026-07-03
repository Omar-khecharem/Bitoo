import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.buffered,
    this.onSeek,
    this.onSeekStart,
    this.onSeekEnd,
  });

  final Duration position;
  final Duration duration;
  final Duration buffered;
  final ValueChanged<Duration>? onSeek;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _sliderValue = 0;
  bool _isDragging = false;

  @override
  void didUpdateWidget(SeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging) {
      _sliderValue = widget.duration.inMilliseconds > 0
          ? widget.position.inMilliseconds / widget.duration.inMilliseconds
          : 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.duration.inSeconds;
    final position = _isDragging
        ? Duration(seconds: (_sliderValue * duration).round())
        : widget.position;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.darkTextPrimary,
            inactiveTrackColor: AppColors.darkTextTertiary.withValues(alpha: 0.2),
            trackHeight: 3,
            thumbColor: AppColors.darkTextPrimary,
            thumbShape: _isDragging
                ? RoundSliderThumbShape(enabledThumbRadius: 7)
                : RoundSliderThumbShape(enabledThumbRadius: 5),
            overlayColor: AppColors.primary500.withValues(alpha: 0.1),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: _sliderValue.clamp(0.0, 1.0),
            onChanged: (value) {
              setState(() {
                _isDragging = true;
                _sliderValue = value;
              });
              widget.onSeekStart?.call();
            },
            onChangeEnd: (value) {
              setState(() => _isDragging = false);
              widget.onSeek?.call(Duration(
                seconds: (value * duration).round(),
              ));
              widget.onSeekEnd?.call();
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.pageHorizontal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextTertiary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                _formatDuration(widget.duration),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextTertiary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$minutes:$seconds';
  }
}

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({
    super.key,
    required this.volume,
    this.onChanged,
  });

  final double volume;
  final ValueChanged<double>? onChanged;

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedOpacity(
        duration: AppDurations.standard,
        opacity: _isHovering ? 1.0 : 0.5,
        child: Row(
          children: [
            Icon(
              widget.volume == 0
                  ? Icons.volume_off_rounded
                  : widget.volume < 0.5
                      ? Icons.volume_down_rounded
                      : Icons.volume_up_rounded,
              size: AppIconSizes.small,
              color: AppColors.darkTextTertiary,
            ),
            SizedBox(width: Spacing.sm),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.darkTextPrimary,
                  inactiveTrackColor: AppColors.darkTextTertiary.withValues(alpha: 0.15),
                  trackHeight: 2,
                  thumbColor: AppColors.darkTextPrimary,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
                  overlayColor: Colors.transparent,
                ),
                child: Slider(
                  value: widget.volume,
                  onChanged: widget.onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
