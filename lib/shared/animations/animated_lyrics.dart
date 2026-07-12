import 'package:flutter/material.dart';
import '../../core/animations/curves.dart';
import '../../core/theme/tokens.dart';

class AnimatedLyricsView extends StatefulWidget {
  final List<LyricLine> lines;
  final Duration currentPosition;
  final Duration? totalDuration;

  const AnimatedLyricsView({
    super.key,
    required this.lines,
    required this.currentPosition,
    this.totalDuration,
  });

  @override
  State<AnimatedLyricsView> createState() => _AnimatedLyricsViewState();
}

class _AnimatedLyricsViewState extends State<AnimatedLyricsView> {
  final ScrollController _scrollController = ScrollController();
  int _currentLineIndex = -1;

  @override
  void didUpdateWidget(AnimatedLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCurrentLine();
  }

  @override
  void initState() {
    super.initState();
    _updateCurrentLine();
  }

  void _updateCurrentLine() {
    final pos = widget.currentPosition.inMilliseconds;
    int newIndex = -1;
    for (int i = widget.lines.length - 1; i >= 0; i--) {
      if (widget.lines[i].timestampMs <= pos) {
        newIndex = i;
        break;
      }
    }
    if (newIndex != _currentLineIndex) {
      setState(() => _currentLineIndex = newIndex);
      _scrollToCurrentLine(newIndex);
    }
  }

  void _scrollToCurrentLine(int index) {
    if (index < 0 || !_scrollController.hasClients) return;
    final offset = (index * 60.0) - (MediaQuery.of(context).size.height * 0.25);
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: AppDurations.normal,
      curve: AnimationCurves.premiumEaseOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lyrics_rounded,
              size: 48,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            SizedBox(height: 12),
            Text(
              'No lyrics available',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return RepaintBoundary(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.3),
          itemCount: widget.lines.length,
          itemBuilder: (context, index) {
            final line = widget.lines[index];
            final isCurrent = index == _currentLineIndex;
            final isPast = index < _currentLineIndex;
            final isUpcoming = index > _currentLineIndex;

            return _LyricLineWidget(
              line: line,
              isCurrent: isCurrent,
              isPast: isPast,
              isUpcoming: isUpcoming,
              currentPosition: widget.currentPosition,
              index: index,
            );
          },
        ),
      ),
    );
  }
}

class _LyricLineWidget extends StatelessWidget {
  final LyricLine line;
  final bool isCurrent;
  final bool isPast;
  final bool isUpcoming;
  final Duration currentPosition;
  final int index;

  const _LyricLineWidget({
    required this.line,
    required this.isCurrent,
    required this.isPast,
    required this.isUpcoming,
    required this.currentPosition,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final progress = line.durationMs > 0
        ? ((currentPosition.inMilliseconds - line.timestampMs) / line.durationMs).clamp(0.0, 1.0)
        : 0.0;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AnimationCurves.premiumEase,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: AnimatedDefaultTextStyle(
          duration: AppDurations.normal,
          curve: AnimationCurves.premiumEase,
          style: TextStyle(
            fontSize: isCurrent ? 22 : (isPast ? 15 : 17),
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w300,
            color: isCurrent
                ? Colors.white
                : Colors.white.withValues(alpha: isPast ? 0.2 : 0.35),
            height: 1.4,
          ),
          child: isCurrent && line.words.isNotEmpty
              ? _SyncedWordText(line: line, progress: progress)
              : Text(line.text, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _SyncedWordText extends StatefulWidget {
  final LyricLine line;
  final double progress;

  const _SyncedWordText({
    required this.line,
    required this.progress,
  });

  @override
  State<_SyncedWordText> createState() => _SyncedWordTextState();
}

class _SyncedWordTextState extends State<_SyncedWordText> {
  @override
  Widget build(BuildContext context) {
    final words = widget.line.words;
    if (words.isEmpty) {
      return Text(widget.line.text, textAlign: TextAlign.center);
    }

    return Text.rich(
      TextSpan(
        children: words.map((word) {
          final wordProgress = widget.line.durationMs > 0
              ? (word.endMs / widget.line.durationMs).clamp(0.0, 1.0)
              : 0.0;
          final isHighlighted = wordProgress <= widget.progress;

          return TextSpan(
            text: '${word.text} ',
            style: TextStyle(
              color: isHighlighted
                  ? const Color(0xFF8B5CF6)
                  : Colors.white.withValues(alpha: 0.6),
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w300,
            ),
          );
        }).toList(),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class LyricLine {
  final String text;
  final int timestampMs;
  final int durationMs;
  final List<LyricWord> words;

  const LyricLine({
    required this.text,
    required this.timestampMs,
    this.durationMs = 3000,
    this.words = const [],
  });
}

class LyricWord {
  final String text;
  final int startMs;
  final int endMs;

  const LyricWord({
    required this.text,
    required this.startMs,
    required this.endMs,
  });
}

class LyricLineBuilder {
  static List<LyricLine> fromLrc(String lrc) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
    for (final line in lrc.split('\n')) {
      final match = regex.firstMatch(line.trim());
      if (match != null) {
        final mins = int.parse(match.group(1)!);
        final secs = int.parse(match.group(2)!);
        final millisStr = match.group(3)!;
        final millis = millisStr.length == 2
            ? int.parse(millisStr) * 10
            : int.parse(millisStr);
        final timestampMs = mins * 60000 + secs * 1000 + millis;
        final text = match.group(4)?.trim() ?? '';
        if (text.isNotEmpty) {
          lines.add(LyricLine(text: text, timestampMs: timestampMs));
        }
      }
    }
    lines.sort((a, b) => a.timestampMs.compareTo(b.timestampMs));
    for (int i = 0; i < lines.length - 1; i++) {
      lines[i] = LyricLine(
        text: lines[i].text,
        timestampMs: lines[i].timestampMs,
        durationMs: lines[i + 1].timestampMs - lines[i].timestampMs,
      );
    }
    return lines;
  }
}
