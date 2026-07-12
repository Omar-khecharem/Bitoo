import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/animations/curves.dart';
import '../../core/theme/tokens.dart';
import 'micro_animations.dart';

class AnimatedAlbumCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Widget? imageWidget;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final double width;
  final double height;
  final bool isFavorite;

  const AnimatedAlbumCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.imageWidget,
    this.onTap,
    this.onPlay,
    this.width = 160,
    this.height = 200,
    this.isFavorite = false,
  });

  @override
  State<AnimatedAlbumCard> createState() => _AnimatedAlbumCardState();
}

class _AnimatedAlbumCardState extends State<AnimatedAlbumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tiltController;
  Animation<double>? _tiltX;
  Animation<double>? _tiltY;

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent event) {
    final box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(event.position);
    final centerX = widget.width / 2;
    final centerY = 180 / 2;
    final deltaX = (localPos.dx - centerX) / centerX;
    final deltaY = (localPos.dy - centerY) / centerY;
    _tiltX = Tween<double>(begin: deltaX * -5, end: deltaX * -5).animate(
      CurvedAnimation(
          parent: _tiltController, curve: AnimationCurves.premiumEase),
    );
    _tiltY = Tween<double>(begin: deltaY * 5, end: deltaY * 5).animate(
      CurvedAnimation(
          parent: _tiltController, curve: AnimationCurves.premiumEase),
    );
    if (!_tiltController.isAnimating) {
      _tiltController.value = 1.0;
    }
  }

  void _onPointerExit(PointerEvent event) {
    _tiltController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        onHover: _onPointerMove,
        onExit: _onPointerExit,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _tiltController,
            builder: (context, child) {
              final tx = _tiltX?.value ?? 0;
              final ty = _tiltY?.value ?? 0;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(ty * pi / 180)
                  ..rotateY(tx * pi / 180),
                child: child,
              );
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C26),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                          child: _buildImage(),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: ScaleOnTap(
                            onTap: widget.onPlay,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ],
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.imageWidget != null) return widget.imageWidget!;
    return Container(
      color: const Color(0xFF262633),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 40,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class AnimatedPlaylistCard extends StatefulWidget {
  final String title;
  final int trackCount;
  final Color? accentColor;
  final VoidCallback? onTap;
  final int index;

  const AnimatedPlaylistCard({
    super.key,
    required this.title,
    required this.trackCount,
    this.accentColor,
    this.onTap,
    this.index = 0,
  });

  @override
  State<AnimatedPlaylistCard> createState() => _AnimatedPlaylistCardState();
}

class _AnimatedPlaylistCardState extends State<AnimatedPlaylistCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.premiumEase),
    );
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.premiumEase),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? const Color(0xFF8B5CF6);

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: widget.index == 0 ? 0 : 4,
        ),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap?.call();
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: _scale.value,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C26),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color.lerp(
                      Colors.white.withValues(alpha: 0.06),
                      accent.withValues(alpha: 0.3),
                      _glow.value,
                    )!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.1 * _glow.value),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.3),
                          accent.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.playlist_play_rounded,
                      color: accent,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${widget.trackCount} tracks',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedTrackTile extends StatefulWidget {
  final int index;
  final String title;
  final String artist;
  final String? artworkUrl;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onPlay;

  const AnimatedTrackTile({
    super.key,
    required this.index,
    required this.title,
    required this.artist,
    this.artworkUrl,
    this.isPlaying = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
    this.onPlay,
  });

  @override
  State<AnimatedTrackTile> createState() => _AnimatedTrackTileState();
}

class _AnimatedTrackTileState extends State<AnimatedTrackTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _highlight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _highlight = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.premiumEase),
    );
  }

  @override
  void didUpdateWidget(AnimatedTrackTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.forward();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: StaggeredFadeIn(
        index: widget.index,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _highlight,
            builder: (context, child) => Container(
              color: Color.lerp(
                Colors.transparent,
                const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                _highlight.value,
              ),
              child: child,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onPlay,
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: widget.isPlaying
                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                            : const Color(0xFF262633),
                      ),
                      child: Center(
                        child: widget.isPlaying
                            ? Icon(Icons.equalizer_rounded,
                                size: 20, color: const Color(0xFF8B5CF6))
                            : Icon(Icons.music_note_rounded,
                                size: 20,
                                color: Colors.white.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: widget.isPlaying
                                ? const Color(0xFF8B5CF6)
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: widget.isPlaying
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.artist,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  HeartBounce(
                    isFilled: widget.isFavorite,
                    onTap: widget.onFavorite,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
