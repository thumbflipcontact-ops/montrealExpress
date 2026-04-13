import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom clipper for creating organic blob shapes
/// Used for promotion cards, avatars, and decorative elements
class BlobClipper extends CustomClipper<Path> {
  BlobClipper({
    this.complexity = 6,
    this.seed = 0,
    this.irregularity = 0.3,
  }) : assert(complexity >= 3, 'Complexity must be at least 3');

  final int complexity;
  final int seed;
  final double irregularity;

  @override
  Path getClip(Size size) {
    final path = Path();
    final random = math.Random(seed);

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radiusX = size.width / 2;
    final radiusY = size.height / 2;

    // Generate random points in a circle
    final points = <Offset>[];
    for (var i = 0; i < complexity; i++) {
      final angle = (i / complexity) * 2 * math.pi;

      // Add some randomness to the radius
      final randomFactor = 1.0 - irregularity + (random.nextDouble() * irregularity * 2);
      final x = centerX + radiusX * math.cos(angle) * randomFactor;
      final y = centerY + radiusY * math.sin(angle) * randomFactor;

      points.add(Offset(x, y));
    }

    // Create smooth curves through the points using cubic bezier
    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 0; i < complexity; i++) {
      final current = points[i];
      final next = points[(i + 1) % complexity];

      // Calculate control points for smooth curves
      final controlPointDistance = 0.5;

      final midX = (current.dx + next.dx) / 2;
      final midY = (current.dy + next.dy) / 2;

      // Add slight randomness to control points
      final controlOffset = irregularity * 0.5;
      final control1X = current.dx + (midX - current.dx) * controlPointDistance;
      final control1Y = current.dy + (midY - current.dy) * controlPointDistance +
          (random.nextDouble() - 0.5) * radiusY * controlOffset;

      final control2X = next.dx - (next.dx - midX) * controlPointDistance;
      final control2Y = next.dy - (next.dy - midY) * controlPointDistance +
          (random.nextDouble() - 0.5) * radiusY * controlOffset;

      path.cubicTo(
        control1X, control1Y,
        control2X, control2Y,
        next.dx, next.dy,
      );
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant BlobClipper oldClipper) {
    return oldClipper.complexity != complexity ||
        oldClipper.seed != seed ||
        oldClipper.irregularity != irregularity;
  }
}

/// Diagonal clipper for dynamic page transitions
class DiagonalClipper extends CustomClipper<Path> {
  DiagonalClipper({
    this.angle = -15.0,
    this.position = DiagonalPosition.topRight,
  });

  final double angle;
  final DiagonalPosition position;

  @override
  Path getClip(Size size) {
    final path = Path();
    final radians = angle * math.pi / 180;
    final offset = size.height * math.tan(radians).abs();

    switch (position) {
      case DiagonalPosition.topLeft:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height - offset);
        path.lineTo(0, size.height);
        path.close();
        break;

      case DiagonalPosition.topRight:
        path.moveTo(0, offset);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        break;

      case DiagonalPosition.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height - offset);
        path.close();
        break;

      case DiagonalPosition.bottomRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height - offset);
        path.lineTo(0, size.height);
        path.close();
        break;
    }

    return path;
  }

  @override
  bool shouldReclip(covariant DiagonalClipper oldClipper) {
    return oldClipper.angle != angle || oldClipper.position != position;
  }
}

enum DiagonalPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Custom rounded rectangle clipper with irregular corners
class OrganicRoundedRectClipper extends CustomClipper<Path> {
  OrganicRoundedRectClipper({
    this.topLeft = 16.0,
    this.topRight = 16.0,
    this.bottomLeft = 16.0,
    this.bottomRight = 16.0,
    this.irregularity = 0.2,
    this.seed = 0,
  });

  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;
  final double irregularity;
  final int seed;

  @override
  Path getClip(Size size) {
    final random = math.Random(seed);
    final path = Path();

    // Helper to add some randomness to radius
    double irregularRadius(double radius) {
      if (irregularity == 0) return radius;
      final variation = radius * irregularity;
      return radius + (random.nextDouble() - 0.5) * variation;
    }

    final tl = irregularRadius(topLeft);
    final tr = irregularRadius(topRight);
    final bl = irregularRadius(bottomLeft);
    final br = irregularRadius(bottomRight);

    // Start from top-left corner
    path.moveTo(tl, 0);

    // Top edge
    path.lineTo(size.width - tr, 0);

    // Top-right corner
    path.quadraticBezierTo(
      size.width, 0,
      size.width, tr,
    );

    // Right edge
    path.lineTo(size.width, size.height - br);

    // Bottom-right corner
    path.quadraticBezierTo(
      size.width, size.height,
      size.width - br, size.height,
    );

    // Bottom edge
    path.lineTo(bl, size.height);

    // Bottom-left corner
    path.quadraticBezierTo(
      0, size.height,
      0, size.height - bl,
    );

    // Left edge
    path.lineTo(0, tl);

    // Top-left corner
    path.quadraticBezierTo(
      0, 0,
      tl, 0,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant OrganicRoundedRectClipper oldClipper) {
    return oldClipper.topLeft != topLeft ||
        oldClipper.topRight != topRight ||
        oldClipper.bottomLeft != bottomLeft ||
        oldClipper.bottomRight != bottomRight ||
        oldClipper.irregularity != irregularity ||
        oldClipper.seed != seed;
  }
}
