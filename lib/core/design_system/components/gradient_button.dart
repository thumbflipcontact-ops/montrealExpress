import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';
import 'package:abdoul_express/core/theme/typography.dart';

/// Gradient button component with press animations and colored shadows
/// Supports icons, loading states, and haptic feedback
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.isLoading = false,
    this.isExpanded = true,
    this.height = 52.0,
    this.borderRadius = 16.0,
    this.shadow,
    this.disabled = false,
    this.textStyle,
  });

  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradient;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool isExpanded;
  final double height;
  final double borderRadius;
  final List<BoxShadow>? shadow;
  final bool disabled;
  final TextStyle? textStyle;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.disabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.disabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.disabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ??
        [AppColors.primaryMain, AppColors.primaryDark];

    final shadow = widget.shadow ??
        (_isPressed ? AppShadows.buttonPressed : AppShadows.button);

    final isDisabled = widget.disabled || widget.onPressed == null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isDisabled || widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: widget.height,
          width: widget.isExpanded ? double.infinity : null,
          padding: widget.isExpanded
              ? null
              : const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: isDisabled
                ? LinearGradient(
                    colors: [
                      AppColors.textDisabled,
                      AppColors.textDisabled,
                    ],
                  )
                : LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: isDisabled ? AppShadows.none : shadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: widget.isLoading
                  ? _buildLoadingIndicator()
                  : _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    final textStyle = widget.textStyle ??
        AppTypography.buttonStyle(color: Colors.white);

    if (widget.icon == null) {
      return Text(widget.text, style: textStyle);
    }

    final iconWidget = Icon(
      widget.icon,
      color: Colors.white,
      size: 20,
    );

    final textWidget = Text(widget.text, style: textStyle);

    if (widget.iconPosition == IconPosition.left) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          textWidget,
          const SizedBox(width: 8),
          iconWidget,
        ],
      );
    }
  }
}

/// Icon position in button
enum IconPosition {
  left,
  right,
}

/// Outline variant of gradient button
class OutlineGradientButton extends StatefulWidget {
  const OutlineGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.isLoading = false,
    this.isExpanded = true,
    this.height = 52.0,
    this.borderRadius = 16.0,
    this.borderWidth = 2.0,
    this.disabled = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradient;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool isExpanded;
  final double height;
  final double borderRadius;
  final double borderWidth;
  final bool disabled;

  @override
  State<OutlineGradientButton> createState() => _OutlineGradientButtonState();
}

class _OutlineGradientButtonState extends State<OutlineGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.disabled && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.disabled && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.disabled && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ??
        [AppColors.primaryMain, AppColors.primaryDark];

    final isDisabled = widget.disabled || widget.onPressed == null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isDisabled || widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height,
          width: widget.isExpanded ? double.infinity : null,
          padding: widget.isExpanded
              ? null
              : const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDisabled ? AppColors.textDisabled : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Container(
            margin: EdgeInsets.all(widget.borderWidth),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(
                widget.borderRadius - widget.borderWidth,
              ),
            ),
            child: Center(
              child: widget.isLoading
                  ? _buildLoadingIndicator(gradient.first)
                  : _buildContent(gradient.first),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildContent(Color color) {
    final textStyle = AppTypography.buttonStyle(color: color);

    if (widget.icon == null) {
      return Text(widget.text, style: textStyle);
    }

    final iconWidget = Icon(
      widget.icon,
      color: color,
      size: 20,
    );

    final textWidget = Text(widget.text, style: textStyle);

    if (widget.iconPosition == IconPosition.left) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          textWidget,
          const SizedBox(width: 8),
          iconWidget,
        ],
      );
    }
  }
}
