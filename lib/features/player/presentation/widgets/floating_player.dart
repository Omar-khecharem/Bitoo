import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class FloatingPlayer extends StatefulWidget {
  const FloatingPlayer({
    super.key,
    required this.imageUrl,
    required this.trackTitle,
    required this.artistName,
    this.isPlaying = false,
    this.progress = 0.0,
    this.onPlayPause,
    this.onTap,
    this.onDismiss,
  });

  final String imageUrl;
  final String trackTitle;
  final String artistName;
  final bool isPlaying;
  final double progress;
  final VoidCallback? onPlayPause;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  State<FloatingPlayer> createState() => _FloatingPlayerState();
}

class _FloatingPlayerState extends State<FloatingPlayer>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset(16, 100);
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        onPanEnd: (_) {
          setState(() => _isDragging = false);
          _snapToEdge();
        },
        child: AnimatedScale(
          scale: _isDragging ? 1.05 : 1.0,
          duration: AppDurations.standard,
          child: GestureDetector(
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 200,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: AppColors.glassOpacityMedium),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.shadowLG,
                  ),
                  child: Row(
                    children: [
                      // Album art
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.lg),
                          bottomLeft: Radius.circular(AppRadius.lg),
                        ),
                        child: Image.network(
                          widget.imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: AppColors.darkSurfaceLight,
                            child: Icon(Icons.music_note_rounded,
                                size: 24, color: AppColors.darkTextTertiary),
                          ),
                        ),
                      ),

                      // Info
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.trackTitle,
                                style: AppTypography.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.artistName,
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.darkTextTertiary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Controls
                      GestureDetector(
                        onTap: widget.onPlayPause,
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                                alpha: AppColors.glassOpacityMedium),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 20,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _snapToEdge() {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX =
        _position.dx > screenWidth / 2 - 100 ? screenWidth - 216 : 16.0;
    setState(() => _position = Offset(targetX, _position.dy));
  }
}
