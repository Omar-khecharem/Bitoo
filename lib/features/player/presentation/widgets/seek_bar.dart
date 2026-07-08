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

class _SeekBarState extends State<SeekBar> with SingleTickerProviderStateMixin {
  double _sliderValue = 0;
  bool _isDragging = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

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
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.duration.inSeconds;
    final position = _isDragging
        ? Duration(seconds: (_sliderValue * duration).round())
        : widget.position;

    final progress = duration > 0 ? _sliderValue : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 40,
          child: GestureDetector(
            onTapDown: (details) {
              final width = context.size?.width ?? 1;
              final ratio = (details.localPosition.dx / width).clamp(0.0, 1.0);
              widget.onSeek?.call(Duration(
                seconds: (ratio * duration).round(),
              ));
            },
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [AppColors.neonIndigo, AppColors.neonRose],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (progress * (MediaQuery.of(context).size.width - 48)).clamp(-8, MediaQuery.of(context).size.width - 56),
                  child: _isDragging
                      ? Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppColors.neonIndigo, AppColors.neonRose],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonIndigo.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.pageHorizontal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '-${_formatDuration(widget.duration - position)}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontFeatures: const [FontFeature.tabularFigures()],
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: Spacing.sm),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                  inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12,
                  trackHeight: 2,
                  thumbColor: Theme.of(context).colorScheme.primary,
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
