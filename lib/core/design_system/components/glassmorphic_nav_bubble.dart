import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';
import 'package:abdoul_express/core/theme/typography.dart';

/// Glassmorphic navigation bubble with frosted glass effect
///
/// Features:
/// - Backdrop blur for glassmorphism effect
/// - Category-aware gradient overlays
/// - Animated selection states
/// - Haptic feedback on interaction
/// - Organic shapes with slight irregularity
class GlassmorphicNavBubble extends StatefulWidget {
  const GlassmorphicNavBubble({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.gradient,
    this.size = NavBubbleSize.medium,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final List<Color>? gradient;
  final NavBubbleSize size;

  @override
  State<GlassmorphicNavBubble> createState() => _GlassmorphicNavBubbleState();
}

class _GlassmorphicNavBubbleState extends State<GlassmorphicNavBubble>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final dimensions = _getDimensions();
    final gradient = widget.gradient ?? [AppColors.primaryMain, AppColors.primaryDark];

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: dimensions.width,
          height: dimensions.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(dimensions.borderRadius),
            boxShadow: widget.isSelected
                ? AppShadows.createColoredShadow(
                    color: gradient.first,
                    opacity: 0.25,
                  )
                : AppShadows.small,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(dimensions.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        )
                      : null,
                  color: widget.isSelected
                      ? null
                      : colorScheme.surface.withValues(alpha: 0.7),
                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.white.withValues(alpha: 0.3)
                        : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(dimensions.borderRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: dimensions.iconSize,
                      color: widget.isSelected
                          ? Colors.white
                          : colorScheme.onSurface,
                    ),
                    if (widget.size != NavBubbleSize.small) ...[
                      SizedBox(height: dimensions.spacing),
                      Text(
                        widget.label,
                        style: AppTypography.buildTextTheme(
                          widget.isSelected ? Brightness.dark : brightness,
                        ).labelSmall!.copyWith(
                          color: widget.isSelected
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: dimensions.fontSize,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _BubbleDimensions _getDimensions() {
    switch (widget.size) {
      case NavBubbleSize.small:
        return const _BubbleDimensions(
          width: 56,
          height: 56,
          iconSize: 24,
          fontSize: 10,
          spacing: 4,
          borderRadius: 16,
        );
      case NavBubbleSize.medium:
        return const _BubbleDimensions(
          width: 80,
          height: 80,
          iconSize: 28,
          fontSize: 11,
          spacing: 6,
          borderRadius: 20,
        );
      case NavBubbleSize.large:
        return const _BubbleDimensions(
          width: 100,
          height: 100,
          iconSize: 32,
          fontSize: 12,
          spacing: 8,
          borderRadius: 24,
        );
    }
  }
}

/// Glassmorphic horizontal navigation bar with bubbles
class GlassmorphicNavBar extends StatelessWidget {
  const GlassmorphicNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.size = NavBubbleSize.small,
  });

  final List<NavBubbleItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final NavBubbleSize size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        boxShadow: AppShadows.large,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            return GlassmorphicNavBubble(
              label: item.label,
              icon: item.icon,
              onTap: () => onItemSelected(index),
              isSelected: selectedIndex == index,
              gradient: item.gradient,
              size: size,
            );
          }),
        ),
      ),
    );
  }
}

/// Navigation bubble item configuration
class NavBubbleItem {
  const NavBubbleItem({
    required this.label,
    required this.icon,
    this.gradient,
  });

  final String label;
  final IconData icon;
  final List<Color>? gradient;
}

/// Size variants for navigation bubbles
enum NavBubbleSize {
  small,
  medium,
  large,
}

class _BubbleDimensions {
  const _BubbleDimensions({
    required this.width,
    required this.height,
    required this.iconSize,
    required this.fontSize,
    required this.spacing,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double iconSize;
  final double fontSize;
  final double spacing;
  final double borderRadius;
}
