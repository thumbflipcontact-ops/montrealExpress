import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Geometric pattern painter for decorative overlays
/// Inspired by West African Adinkra patterns
///
/// Features:
/// - Repeating geometric patterns
/// - Seed-based randomness for variations
/// - Adjustable opacity and color
/// - Multiple pattern types
class GeometricPatternPainter extends CustomPainter {
  GeometricPatternPainter({
    this.color = Colors.white,
    this.opacity = 0.1,
    this.spacing = 40.0,
    this.seed = 0,
    this.patternType = PatternType.adinkra,
  });

  final Color color;
  final double opacity;
  final double spacing;
  final int seed;
  final PatternType patternType;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final random = math.Random(seed);

    switch (patternType) {
      case PatternType.adinkra:
        _drawAdinkraPattern(canvas, size, paint, random);
        break;
      case PatternType.circles:
        _drawCirclesPattern(canvas, size, paint, random);
        break;
      case PatternType.diamonds:
        _drawDiamondsPattern(canvas, size, paint, random);
        break;
    }
  }

  void _drawAdinkraPattern(Canvas canvas, Size size, Paint paint, math.Random random) {
    // Draw a grid of Adinkra-inspired symbols
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final centerX = x + spacing / 2;
        final centerY = y + spacing / 2;
        final radius = spacing * 0.3;

        // Draw a stylized symbol (combination of circles and crosses)
        // Outer circle
        canvas.drawCircle(
          Offset(centerX, centerY),
          radius,
          paint,
        );

        // Inner cross
        final crossSize = radius * 0.6;
        canvas.drawLine(
          Offset(centerX - crossSize, centerY),
          Offset(centerX + crossSize, centerY),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY - crossSize),
          Offset(centerX, centerY + crossSize),
          paint,
        );

        // Add small dots at cardinal points with slight randomness
        final dotRadius = 2.0;
        for (var i = 0; i < 4; i++) {
          final angle = (i * math.pi / 2) + (random.nextDouble() - 0.5) * 0.2;
          final dotDistance = radius * 1.3;
          final dotX = centerX + math.cos(angle) * dotDistance;
          final dotY = centerY + math.sin(angle) * dotDistance;

          canvas.drawCircle(
            Offset(dotX, dotY),
            dotRadius,
            Paint()
              ..color = color.withValues(alpha: opacity)
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }

  void _drawCirclesPattern(Canvas canvas, Size size, Paint paint, math.Random random) {
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final centerX = x + spacing / 2 + (random.nextDouble() - 0.5) * 10;
        final centerY = y + spacing / 2 + (random.nextDouble() - 0.5) * 10;
        final radius = spacing * 0.25 * (0.8 + random.nextDouble() * 0.4);

        canvas.drawCircle(
          Offset(centerX, centerY),
          radius,
          paint,
        );
      }
    }
  }

  void _drawDiamondsPattern(Canvas canvas, Size size, Paint paint, math.Random random) {
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final centerX = x + spacing / 2;
        final centerY = y + spacing / 2;
        final diamondSize = spacing * 0.3;

        final path = Path()
          ..moveTo(centerX, centerY - diamondSize)
          ..lineTo(centerX + diamondSize, centerY)
          ..lineTo(centerX, centerY + diamondSize)
          ..lineTo(centerX - diamondSize, centerY)
          ..close();

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GeometricPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.spacing != spacing ||
        oldDelegate.seed != seed ||
        oldDelegate.patternType != patternType;
  }
}

enum PatternType {
  adinkra,
  circles,
  diamonds,
}
