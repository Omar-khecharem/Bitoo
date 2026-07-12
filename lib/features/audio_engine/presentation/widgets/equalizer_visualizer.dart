import 'package:flutter/material.dart';

class EqualizerVisualizer extends StatefulWidget {
  final List<double> bands;
  final bool isEnabled;
  final void Function(int index, double value)? onBandChanged;

  const EqualizerVisualizer({
    super.key,
    required this.bands,
    this.isEnabled = true,
    this.onBandChanged,
  });

  @override
  State<EqualizerVisualizer> createState() => _EqualizerVisualizerState();
}

class _EqualizerVisualizerState extends State<EqualizerVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animateBands() {
    _animController.forward(from: 0);
  }

  @override
  void didUpdateWidget(EqualizerVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bands != widget.bands) {
      _animateBands();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return SizedBox(
          height: 220,
          child: CustomPaint(
            painter: _EQGridPainter(isEnabled: widget.isEnabled),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(widget.bands.length, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: i < widget.bands.length - 1 ? 2 : 0),
                    child: _EQSliderBar(
                      value: widget.bands[i] * _animController.value,
                      isEnabled: widget.isEnabled,
                      onChanged: (v) {
                        widget.onBandChanged?.call(i, v);
                        _animateBands();
                      },
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class _EQSliderBar extends StatefulWidget {
  final double value;
  final bool isEnabled;
  final ValueChanged<double> onChanged;

  const _EQSliderBar({
    required this.value,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  State<_EQSliderBar> createState() => _EQSliderBarState();
}

class _EQSliderBarState extends State<_EQSliderBar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            final height = constraints.maxHeight;
            final normalized = 1.0 - (details.localPosition.dy / height);
            final clamped = (normalized.clamp(0.0, 1.0) * 2 - 1);
            widget.onChanged(clamped);
          },
          child: CustomPaint(
            painter: _EQBarPainter(
              value: widget.value,
              isEnabled: widget.isEnabled,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        );
      },
    );
  }
}

class _EQGridPainter extends CustomPainter {
  final bool isEnabled;

  _EQGridPainter({this.isEnabled = true});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: isEnabled ? 0.04 : 0.02)
      ..strokeWidth = 0.5;

    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: isEnabled ? 0.08 : 0.04)
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), centerPaint);
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EQGridPainter oldDelegate) =>
      oldDelegate.isEnabled != isEnabled;
}

class _EQBarPainter extends CustomPainter {
  final double value;
  final bool isEnabled;

  _EQBarPainter({required this.value, required this.isEnabled});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final absValue = value.abs().clamp(0.0, 1.0);
    final barHeight = size.height * 0.9 * absValue;
    final barWidth = size.width * 0.65;
    final x = (size.width - barWidth) / 2;
    final isPositive = value >= 0;
    final y = isPositive ? centerY - barHeight : centerY;

    final alpha = isEnabled ? 1.0 : 0.3;
    final color = isPositive
        ? Color.lerp(
            const Color(0xFF8B5CF6), const Color(0xFF6366F1), absValue)!
        : Color.lerp(
            const Color(0xFFF43F5E), const Color(0xFFFB7185), absValue)!;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, barWidth, barHeight),
      Radius.circular(barWidth / 2),
    );

    canvas.drawRRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: isPositive ? Alignment.bottomCenter : Alignment.topCenter,
          end: isPositive ? Alignment.topCenter : Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.3 * alpha),
            color.withValues(alpha: 1.0 * alpha),
          ],
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight)),
    );

    canvas.drawCircle(
      Offset(size.width / 2, y),
      3.5,
      Paint()..color = color.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(covariant _EQBarPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.isEnabled != isEnabled;
}

class EQFrequencyLabels extends StatelessWidget {
  final bool isEnabled;

  const EQFrequencyLabels({super.key, this.isEnabled = true});

  static const _frequencies = [
    '31',
    '62',
    '125',
    '250',
    '500',
    '1k',
    '2k',
    '4k',
    '8k',
    '16k'
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _frequencies
          .map((f) => Expanded(
                child: Text(
                  f,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        Colors.white.withValues(alpha: isEnabled ? 0.4 : 0.2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
