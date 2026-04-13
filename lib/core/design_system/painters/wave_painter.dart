import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for creating organic wave shapes
/// Used as dividers between sections for "sand dune" effect
class WavePainter extends CustomPainter {
  WavePainter({
    required this.color,
    this.secondColor,
    this.amplitude = 20.0,
    this.frequency = 2.0,
    this.offset = 0.0,
    this.paintingStyle = PaintingStyle.fill,
  });

  final Color color;
  final Color? secondColor;
  final double amplitude;
  final double frequency;
  final double offset;
  final PaintingStyle paintingStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = paintingStyle
      ..strokeWidth = 2.0;

    if (secondColor != null) {
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, secondColor!],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.color = color;
    }

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);

    // Draw line to start of wave
    path.lineTo(0, size.height / 2);

    // Create smooth wave using quadratic bezier curves
    final waveWidth = size.width / frequency;

    for (var i = 0; i <= frequency; i++) {
      final x1 = i * waveWidth;
      final x2 = x1 + (waveWidth / 2);
      final x3 = x1 + waveWidth;

      final y1 = size.height / 2 +
                 amplitude * math.sin((i * math.pi) + (offset / 10));
      final y2 = size.height / 2 +
                 amplitude * math.sin((i * math.pi + math.pi / 2) + (offset / 10));
      final y3 = size.height / 2 +
                 amplitude * math.sin(((i + 1) * math.pi) + (offset / 10));

      if (i == 0) {
        path.lineTo(x1, y1);
      }

      path.quadraticBezierTo(x2, y2, x3, y3);
    }

    // Complete the path
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.secondColor != secondColor ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.frequency != frequency ||
        oldDelegate.offset != offset ||
        oldDelegate.paintingStyle != paintingStyle;
  }
}

/// Animated wave divider widget
class WaveDivider extends StatelessWidget {
  const WaveDivider({
    super.key,
    required this.height,
    required this.color,
    this.secondColor,
    this.amplitude = 20.0,
    this.frequency = 2.0,
    this.offset = 0.0,
  });

  final double height;
  final Color color;
  final Color? secondColor;
  final double amplitude;
  final double frequency;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: WavePainter(
          color: color,
          secondColor: secondColor,
          amplitude: amplitude,
          frequency: frequency,
          offset: offset,
        ),
      ),
    );
  }
}

/// Animated wave divider with automatic animation
class AnimatedWaveDivider extends StatefulWidget {
  const AnimatedWaveDivider({
    super.key,
    required this.height,
    required this.color,
    this.secondColor,
    this.amplitude = 20.0,
    this.frequency = 2.0,
    this.animationDuration = const Duration(seconds: 3),
  });

  final double height;
  final Color color;
  final Color? secondColor;
  final double amplitude;
  final double frequency;
  final Duration animationDuration;

  @override
  State<AnimatedWaveDivider> createState() => _AnimatedWaveDividerState();
}

class _AnimatedWaveDividerState extends State<AnimatedWaveDivider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 100.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return WaveDivider(
          height: widget.height,
          color: widget.color,
          secondColor: widget.secondColor,
          amplitude: widget.amplitude,
          frequency: widget.frequency,
          offset: _animation.value,
        );
      },
    );
  }
}
