import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';
import 'package:abdoul_express/core/theme/typography.dart';

/// Overlapping stat card with gradient and glassmorphic design
///
/// Features:
/// - Gradient background
/// - Backdrop blur for glassmorphic effect
/// - Large numeric value display
/// - Icon and label
/// - Tap interaction
class StatCard extends StatefulWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.gradient,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final List<Color>? gradient;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gradient =
        widget.gradient ?? [AppColors.primaryMain, AppColors.primaryDark];

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 145,
          height: 125,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.createColoredShadow(
              color: gradient.first,
              opacity: 0.25,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 20),
                    ),
                    const Spacer(),
                    // Value
                    Text(
                      widget.value,
                      style: AppTypography.buildTextTheme(Brightness.dark)
                          .headlineLarge!
                          .copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 32,
                          ),
                    ),
                    const SizedBox(height: 2),
                    // Label
                    Text(
                      widget.label,
                      style: AppTypography.buildTextTheme(Brightness.dark)
                          .bodySmall!
                          .copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Row of overlapping stat cards with staggered layout
class OverlappingStatCards extends StatelessWidget {
  const OverlappingStatCards({super.key, required this.cards});

  final List<StatCard> cards;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          for (var i = 0; i < cards.length; i++)
            Positioned(
              left: i * 110.0,
              top: i.isEven ? 0 : 15,
              child: cards[i],
            ),
        ],
      ),
    );
  }
}
