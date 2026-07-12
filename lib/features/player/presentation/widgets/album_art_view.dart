import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

enum AlbumArtMode { standard, vinyl, visualizer }

class AlbumArtView extends StatefulWidget {
  const AlbumArtView({
    super.key,
    required this.imageUrl,
    required this.size,
    this.mode = AlbumArtMode.standard,
    this.bpm = 120,
    this.isPlaying = false,
    this.amplitude = 0.3,
    this.onModeToggle,
  });

  final String imageUrl;
  final double size;
  final AlbumArtMode mode;
  final double bpm;
  final bool isPlaying;
  final double amplitude;
  final VoidCallback? onModeToggle;

  @override
  State<AlbumArtView> createState() => _AlbumArtViewState();
}

class _AlbumArtViewState extends State<AlbumArtView>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _vinylController;

  @override
  void initState() {
    super.initState();
    final beatDuration = (60.0 / widget.bpm);
    _breatheController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (beatDuration * 1000).round()),
    );
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isPlaying) {
      _breatheController.repeat();
      _vinylController.repeat();
    }
  }

  @override
  void didUpdateWidget(AlbumArtView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _breatheController.repeat();
        _vinylController.repeat();
      } else {
        _breatheController.stop();
        _vinylController.stop();
      }
    }
    if (widget.bpm != oldWidget.bpm) {
      final beatDuration = (60.0 / widget.bpm);
      _breatheController.duration =
          Duration(milliseconds: (beatDuration * 1000).round());
    }
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _vinylController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onModeToggle,
      child: switch (widget.mode) {
        AlbumArtMode.standard => _buildStandard(),
        AlbumArtMode.vinyl => _buildVinyl(),
        AlbumArtMode.visualizer => _buildWithVisualizer(),
      },
    );
  }

  Widget _buildStandard() {
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, child) {
        final pulse = 1.0 + 0.015 * sin(_breatheController.value * 2 * pi);
        return Transform.scale(scale: pulse, child: child);
      },
      child: RepaintBoundary(child: _buildPremiumArt()),
    );
  }

  Widget _buildVinyl() {
    return AnimatedBuilder(
      animation: _vinylController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _vinylController.value * 2 * pi,
          child: child,
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _VinylPainter(),
          child: Padding(
            padding: EdgeInsets.all(widget.size * 0.08),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.size * 0.42),
              child: _buildArtImage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWithVisualizer() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          _buildPremiumArt(),
          AnimatedBuilder(
            animation: _breatheController,
            builder: (context, _) {
              return CustomPaint(
                painter: _CircularWavePainter(
                  amplitude: widget.amplitude,
                  color: Theme.of(context).colorScheme.primary,
                  isPlaying: widget.isPlaying,
                  time: _breatheController.value,
                ),
                size: Size(widget.size, widget.size),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumArt() {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          if (widget.isPlaying) _buildSoundWaves(),
          Center(
            child: Container(
              width: widget.size * 0.88,
              height: widget.size * 0.88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withValues(alpha: 0.6),
                    cs.secondary.withValues(alpha: 0.3)
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: cs.secondary.withValues(alpha: 0.2),
                    blurRadius: 60,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildArtImage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundWaves() {
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SoundWavePainter(
            amplitude: widget.amplitude,
            time: _breatheController.value,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  Widget _buildArtImage() {
    final path = widget.imageUrl;
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }
    if (path.isNotEmpty && File(path).existsSync()) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        'B',
        style: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w900,
          fontSize: widget.size * 0.45,
          color: Colors.white.withValues(alpha: 0.3),
          letterSpacing: -4,
        ),
      ),
    );
  }
}

class _VinylPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    // Outer edge
    final outerPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, outerPaint);

    // Subtle rim highlight
    final rimPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2A2A2A),
          const Color(0xFF1A1A1A),
          const Color(0xFF2A2A2A),
        ],
        stops: [0.85, 0.92, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius, rimPaint);

    // Grooves
    for (var i = 0; i < 20; i++) {
      final radius = outerRadius * (0.55 + i * 0.015);
      final groovePaint = Paint()
        ..color =
            Color.fromRGBO(255, 255, 255, (0.01 + i * 0.002).clamp(0.0, 0.05))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawCircle(center, radius, groovePaint);
    }

    // Label area (white circle in center)
    final labelRadius = outerRadius * 0.22;
    final labelPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawCircle(center, labelRadius, labelPaint);

    // Label hole
    canvas.drawCircle(
        center, labelRadius * 0.25, Paint()..color = const Color(0xFF1A1A1A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SoundWavePainter extends CustomPainter {
  _SoundWavePainter({
    required this.amplitude,
    required this.time,
    required this.color,
  });

  final double amplitude;
  final double time;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = 24;
    const maxBars = 24;
    final barWidth = size.width / (maxBars * 2.5);
    final spacing = barWidth * 1.5;
    final totalWidth = barCount * (barWidth + spacing);
    final startX = (size.width - totalWidth) / 2 + barWidth / 2;

    for (var i = 0; i < barCount; i++) {
      final dynamicVal = sin(time * 4 + i * 0.8) * 0.5 + 0.5;
      final height =
          (size.height * 0.35) * (0.2 + 0.8 * dynamicVal) * amplitude;
      final opacity = 0.1 + 0.3 * dynamicVal;
      final x = startX + i * (barWidth + spacing);
      final y = (size.height - height) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, height),
          const Radius.circular(2),
        ),
        Paint()..color = color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SoundWavePainter oldDelegate) =>
      oldDelegate.amplitude != amplitude || oldDelegate.time != time;
}

class _CircularWavePainter extends CustomPainter {
  _CircularWavePainter({
    required this.amplitude,
    required this.color,
    required this.isPlaying,
    required this.time,
  });

  final double amplitude;
  final Color color;
  final bool isPlaying;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isPlaying) return;
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.38;

    for (var ring = 0; ring < 3; ring++) {
      final phase = ring * 0.3;
      final path = Path();
      final points = 32;

      for (var i = 0; i <= points; i++) {
        final angle = (i / points) * 2 * pi;
        final wave = sin(angle * 4 + time * 8 + phase);
        final r = baseRadius + amplitude * 20 * wave;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.15 - ring * 0.04)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 - ring * 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularWavePainter oldDelegate) =>
      oldDelegate.amplitude != amplitude ||
      oldDelegate.isPlaying != isPlaying ||
      oldDelegate.time != time;
}
