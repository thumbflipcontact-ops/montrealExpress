import 'package:flutter/material.dart';
import 'package:abdoul_express/core/design_system/painters/blob_clipper.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';

/// Blob-shaped avatar with organic edges and gradient background
///
/// Features:
/// - Organic blob shape using BlobClipper
/// - Seed-based randomness for consistent shape
/// - Gradient background support
/// - Optional border
/// - Icon or image content
class BlobAvatar extends StatelessWidget {
  const BlobAvatar({
    super.key,
    this.size = 100,
    this.gradient,
    this.backgroundColor,
    this.child,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.borderWidth = 3,
    this.borderColor,
    this.seed = 42,
    this.complexity = 7,
    this.irregularity = 0.15,
  });

  final double size;
  final List<Color>? gradient;
  final Color? backgroundColor;
  final Widget? child;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final double borderWidth;
  final Color? borderColor;
  final int seed;
  final int complexity;
  final double irregularity;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? [
      AppColors.primaryMain,
      AppColors.primaryDark,
    ];
    final effectiveBorderColor = borderColor ?? Colors.white;

    return Container(
      width: size + (borderWidth * 2),
      height: size + (borderWidth * 2),
      decoration: BoxDecoration(
        boxShadow: AppShadows.createColoredShadow(
          color: effectiveGradient.first,
          opacity: 0.3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Border blob
          ClipPath(
            clipper: BlobClipper(
              complexity: complexity,
              seed: seed,
              irregularity: irregularity,
            ),
            child: Container(
              width: size + (borderWidth * 2),
              height: size + (borderWidth * 2),
              color: effectiveBorderColor,
            ),
          ),
          // Inner blob with gradient
          ClipPath(
            clipper: BlobClipper(
              complexity: complexity,
              seed: seed,
              irregularity: irregularity,
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: effectiveGradient,
                ),
                color: backgroundColor,
              ),
              child: child ?? (icon != null
                  ? Icon(
                      icon,
                      size: iconSize ?? size * 0.5,
                      color: iconColor ?? Colors.white,
                    )
                  : null),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large blob avatar with image support
class BlobAvatarImage extends StatelessWidget {
  const BlobAvatarImage({
    super.key,
    required this.imageUrl,
    this.size = 100,
    this.gradient,
    this.borderWidth = 3,
    this.borderColor,
    this.seed = 42,
    this.complexity = 7,
    this.irregularity = 0.15,
  });

  final String imageUrl;
  final double size;
  final List<Color>? gradient;
  final double borderWidth;
  final Color? borderColor;
  final int seed;
  final int complexity;
  final double irregularity;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? [
      AppColors.primaryMain,
      AppColors.primaryDark,
    ];
    final effectiveBorderColor = borderColor ?? Colors.white;

    return Container(
      width: size + (borderWidth * 2),
      height: size + (borderWidth * 2),
      decoration: BoxDecoration(
        boxShadow: AppShadows.createColoredShadow(
          color: effectiveGradient.first,
          opacity: 0.3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Border blob
          ClipPath(
            clipper: BlobClipper(
              complexity: complexity,
              seed: seed,
              irregularity: irregularity,
            ),
            child: Container(
              width: size + (borderWidth * 2),
              height: size + (borderWidth * 2),
              color: effectiveBorderColor,
            ),
          ),
          // Inner blob with image
          ClipPath(
            clipper: BlobClipper(
              complexity: complexity,
              seed: seed,
              irregularity: irregularity,
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
