import 'package:flutter/material.dart';
import '../../core/animations/curves.dart';
import '../../core/theme/tokens.dart';
import 'micro_animations.dart';

class NowPlayingBar extends StatefulWidget {
  final String title;
  final String artist;
  final String? artworkUrl;
  final Widget? artworkWidget;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;

  const NowPlayingBar({
    super.key,
    required this.title,
    required this.artist,
    this.artworkUrl,
    this.artworkWidget,
    required this.position,
    required this.duration,
    required this.isPlaying,
    this.onTap,
    this.onPlayPause,
    this.onNext,
  });

  @override
  State<NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends State<NowPlayingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );
    _slideUp = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AnimationCurves.premiumEaseOut,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.duration.inMilliseconds > 0
        ? widget.position.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;

    return RepaintBoundary(
      child: SlideTransition(
        position: _slideUp,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C26),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: AlwaysStoppedAnimation(progress),
                  builder: (context, child) => ClipRRect(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF8B5CF6),
                      ),
                      minHeight: 2,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    children: [
                      ScaleOnTap(
                        onTap: widget.onTap,
                        child: Hero(
                          tag: 'now_playing_art',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 44,
                              color: const Color(0xFF262633),
                              child: _buildArtwork(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onTap,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: AppDurations.normal,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                child: Text(
                                  widget.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 1),
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
                      ),
                      ScaleOnTap(
                        onTap: widget.onPlayPause,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: AnimatedSwitcher(
                            duration: AppDurations.fast,
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              widget.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              key: ValueKey(widget.isPlaying),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ScaleOnTap(
                        onTap: widget.onNext,
                        child: Icon(
                          Icons.skip_next_rounded,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork() {
    if (widget.artworkWidget != null) return widget.artworkWidget!;
    return Center(
      child: Icon(
        Icons.music_note_rounded,
        size: 20,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }
}

class VinylRotationWidget extends StatefulWidget {
  final Widget child;
  final bool isPlaying;
  final double size;

  const VinylRotationWidget({
    super.key,
    required this.child,
    required this.isPlaying,
    this.size = 280,
  });

  @override
  State<VinylRotationWidget> createState() => _VinylRotationWidgetState();
}

class _VinylRotationWidgetState extends State<VinylRotationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.vinyl,
    );
    if (widget.isPlaying) _controller.repeat();
  }

  @override
  void didUpdateWidget(VinylRotationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: child,
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF12121A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(child: widget.child),
              Center(
                child: Container(
                  width: widget.size * 0.15,
                  height: widget.size * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF262633),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
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

class AlbumArtParallax extends StatefulWidget {
  final Widget child;
  final double scrollSpeed;

  const AlbumArtParallax({
    super.key,
    required this.child,
    this.scrollSpeed = 0.3,
  });

  @override
  State<AlbumArtParallax> createState() => _AlbumArtParallaxState();
}

class _AlbumArtParallaxState extends State<AlbumArtParallax>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.slower,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _controller.value * 3 * widget.scrollSpeed),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
