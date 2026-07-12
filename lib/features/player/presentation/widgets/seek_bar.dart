import 'package:flutter/material.dart';
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
  bool _isHovering = false;

  @override
  void didUpdateWidget(SeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging) {
      _sliderValue = widget.duration.inMilliseconds > 0
          ? widget.position.inMilliseconds / widget.duration.inMilliseconds
          : 0.0;
    }
  }

  void _onTapDown(TapDownDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final width = box.size.width;
    final ratio = (details.localPosition.dx / width).clamp(0.0, 1.0);
    setState(() {
      _sliderValue = ratio;
      _isDragging = true;
    });
    widget.onSeekStart?.call();
  }

  void _onTapUp(TapUpDetails details) {
    final duration = widget.duration.inSeconds;
    setState(() => _isDragging = false);
    widget.onSeek?.call(Duration(
      seconds: (_sliderValue * duration).round(),
    ));
    widget.onSeekEnd?.call();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final width = box.size.width;
    setState(() {
      _sliderValue = ((details.localPosition.dx / width).clamp(0.0, 1.0));
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final duration = widget.duration.inSeconds;
    setState(() => _isDragging = false);
    widget.onSeek?.call(Duration(
      seconds: (_sliderValue * duration).round(),
    ));
    widget.onSeekEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final duration = widget.duration.inSeconds;
    final position = _isDragging
        ? Duration(seconds: (_sliderValue * duration).round())
        : widget.position;
    final progress = duration > 0 ? _sliderValue : 0.0;
    final bufferedProgress = widget.duration.inMilliseconds > 0
        ? widget.buffered.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Seek track — Apple Music style, always shows thumb
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 40,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onHorizontalDragStart: (_) {
                setState(() => _isDragging = true);
                widget.onSeekStart?.call();
              },
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovering = true),
                onExit: (_) => setState(() => _isHovering = false),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background track
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: cs.onSurface.withValues(alpha: 0.08),
                      ),
                    ),
                    // Buffered progress
                    FractionallySizedBox(
                      widthFactor: bufferedProgress.clamp(0.0, 1.0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: cs.onSurface.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    // Playback progress
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [cs.primary, cs.secondary],
                          ),
                        ),
                      ),
                    ),
                    // Thumb — always visible like Apple Music
                    Positioned(
                      left: (progress * (MediaQuery.of(context).size.width - 72)).clamp(-10, MediaQuery.of(context).size.width - 86),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: _isDragging || _isHovering ? 18 : 8,
                        height: _isDragging || _isHovering ? 18 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary,
                          boxShadow: _isDragging || _isHovering
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Time labels — Apple Music style
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '-${_formatDuration(widget.duration - position)}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withValues(alpha: 0.5),
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
