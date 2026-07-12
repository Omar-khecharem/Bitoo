import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';

enum WaveMode { bars, circular, particles }

class WaveAnimation extends StatefulWidget {
  const WaveAnimation({
    super.key,
    required this.amplitudes,
    this.mode = WaveMode.bars,
    this.color,
    this.isPlaying = false,
    this.onModeToggle,
  });

  final List<double> amplitudes;
  final WaveMode mode;
  final Color? color;
  final bool isPlaying;
  final VoidCallback? onModeToggle;

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _displayAmplitudes = List.filled(16, 0.0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(_updateAmplitudes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAmplitudes() {
    for (var i = 0; i < _displayAmplitudes.length; i++) {
      final target = i < widget.amplitudes.length ? widget.amplitudes[i] : 0.0;
      _displayAmplitudes[i] += (target - _displayAmplitudes[i]) * 0.3;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onModeToggle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (widget.mode) {
          WaveMode.bars => _buildBars(),
          WaveMode.circular => _buildCircular(),
          WaveMode.particles => _buildParticles(),
        },
      ),
    );
  }

  Widget _buildBars() {
    final color = widget.color ?? AppColors.primary500;
    final barCount = _displayAmplitudes.length;
    final spacing = 4.0;
    final totalSpacing = spacing * (barCount - 1);
    final barWidth = (200 - totalSpacing) / barCount;

    return SizedBox(
      height: 80,
      width: 200,
      child: CustomPaint(
        painter: _BarWavePainter(
          amplitudes: _displayAmplitudes,
          color: color,
          barWidth: barWidth,
          spacing: spacing,
        ),
      ),
    );
  }

  Widget _buildCircular() {
    return SizedBox(
      height: 200,
      width: 200,
      child: CustomPaint(
        painter: _CircularWavePainter(
          amplitudes: _displayAmplitudes,
          color: widget.color ?? AppColors.primary500,
        ),
      ),
    );
  }

  Widget _buildParticles() {
    return SizedBox(
      height: 200,
      width: 200,
      child: CustomPaint(
        painter: _ParticlePainter(
          amplitudes: _displayAmplitudes,
          color: widget.color ?? AppColors.primary500,
          time: _controller.value,
        ),
      ),
    );
  }
}

class _BarWavePainter extends CustomPainter {
  _BarWavePainter({
    required this.amplitudes,
    required this.color,
    required this.barWidth,
    required this.spacing,
  });

  final List<double> amplitudes;
  final Color color;
  final double barWidth;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < amplitudes.length; i++) {
      final height = amplitudes[i].clamp(0.0, 1.0) * size.height;
      final x = i * (barWidth + spacing);
      final y = size.height - height;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, height),
        Radius.circular(barWidth / 2),
      );

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.6),
          color,
        ],
      );

      canvas.drawRRect(
        rrect,
        Paint()..shader = gradient.createShader(rrect.outerRect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarWavePainter oldDelegate) => true;
}

class _CircularWavePainter extends CustomPainter {
  _CircularWavePainter({required this.amplitudes, required this.color});

  final List<double> amplitudes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.3;
    final path = Path();
    final count = amplitudes.length;

    for (var i = 0; i <= count; i++) {
      final angle = (i / count) * 2 * pi - pi / 2;
      final amp = amplitudes[i >= count ? i - count : i];
      final r = baseRadius + amp * 30;

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
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );

    for (var i = 0; i <= count; i++) {
      final angle = (i / count) * 2 * pi - pi / 2;
      final amp = amplitudes[i >= count ? i - count : i];
      final r = baseRadius + amp * 30;

      canvas.drawCircle(
        Offset(center.dx + r * cos(angle), center.dy + r * sin(angle)),
        3,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularWavePainter oldDelegate) => true;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.amplitudes,
    required this.color,
    required this.time,
  });

  final List<double> amplitudes;
  final Color color;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rng = Random(time.toInt());

    for (var i = 0; i < 30; i++) {
      final angle = rng.nextDouble() * 2 * pi + time * 0.5;
      final speed = 0.5 + rng.nextDouble() * 1.5;
      final radius = 20 +
          (time * speed % 100) +
          (amplitudes.isNotEmpty
              ? amplitudes[i % amplitudes.length] * 40
              : 0.0);

      final x = center.dx + radius * cos(angle + time * speed);
      final y = center.dy + radius * sin(angle + time * speed);

      final opacity = (1.0 - (radius / 150).clamp(0.0, 1.0));
      final particleSize = 1.0 +
          (amplitudes.isNotEmpty ? amplitudes[i % amplitudes.length] * 3 : 1.0);

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        Paint()..color = color.withValues(alpha: opacity * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.time != time;
}
