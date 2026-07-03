import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';

class FloatingLyricsOverlay extends StatefulWidget {
  const FloatingLyricsOverlay({
    super.key,
    required this.lyrics,
    required this.currentPosition,
  });

  final List<LyricLine> lyrics;
  final Duration currentPosition;

  @override
  State<FloatingLyricsOverlay> createState() => _FloatingLyricsOverlayState();
}

class _FloatingLyricsOverlayState extends State<FloatingLyricsOverlay> {
  late ScrollController _scrollController;
  int _currentLineIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(FloatingLyricsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCurrentLine();
  }

  void _updateCurrentLine() {
    final pos = widget.currentPosition.inMilliseconds;
    var newIndex = 0;
    for (var i = 0; i < widget.lyrics.length; i++) {
      if (pos >= widget.lyrics[i].startMs) {
        newIndex = i;
      }
    }
    if (newIndex != _currentLineIndex) {
      _currentLineIndex = newIndex;
      _scrollToCurrent();
    }
  }

  void _scrollToCurrent() {
    if (!_scrollController.hasClients) return;
    final offset = (_currentLineIndex - 2) * 60.0;
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: AppDurations.standard,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Spacing.lg, MediaQuery.of(context).padding.top + Spacing.lg,
                  Spacing.lg, Spacing.md,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lyrics_rounded,
                      size: AppIconSizes.small,
                      color: AppColors.darkTextPrimary,
                    ),
                    SizedBox(width: Spacing.sm),
                    Text(
                      'Lyrics',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white.withValues(alpha: 0.06),
                height: 1,
              ),

              // Lyrics list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xl,
                    vertical: Spacing.xxl,
                  ),
                  itemCount: widget.lyrics.length,
                  itemBuilder: (context, index) {
                    final line = widget.lyrics[index];
                    final isCurrent = index == _currentLineIndex;
                    final isPast = index < _currentLineIndex;

                    return AnimatedDefaultTextStyle(
                      duration: AppDurations.standard,
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: isCurrent ? 26 : (isPast ? 16 : 18),
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isCurrent
                            ? AppColors.darkTextPrimary
                            : isPast
                                ? AppColors.darkTextTertiary.withValues(alpha: 0.5)
                                : AppColors.darkTextSecondary.withValues(alpha: 0.4),
                        height: 1.8,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: Spacing.sm,
                          bottom: Spacing.sm,
                          left: isCurrent ? Spacing.lg : 0,
                        ),
                        child: isCurrent
                            ? _HighlightedText(line.text)
                            : Text(line.text),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightedText extends StatefulWidget {
  const _HighlightedText(this.text);
  final String text;

  @override
  State<_HighlightedText> createState() => _HighlightedTextState();
}

class _HighlightedTextState extends State<_HighlightedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            AppColors.primary500,
            AppColors.darkTextPrimary,
            AppColors.darkTextPrimary,
            AppColors.primary500,
          ],
          stops: [
            _controller.value - 0.2,
            _controller.value,
            _controller.value + 0.3,
            _controller.value + 0.5,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(widget.text),
    );
  }
}

class LyricLine {
  final int startMs;
  final int endMs;
  final String text;
  final List<LyricWord> words;

  const LyricLine({
    required this.startMs,
    required this.endMs,
    required this.text,
    this.words = const [],
  });
}

class LyricWord {
  final int startMs;
  final int endMs;
  final String text;

  const LyricWord({
    required this.startMs,
    required this.endMs,
    required this.text,
  });
}
