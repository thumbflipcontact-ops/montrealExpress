import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';
import 'package:abdoul_express/core/theme/typography.dart';

/// Organic quantity stepper with curved buttons and smooth animations
class OrganicQuantityStepper extends StatefulWidget {
  const OrganicQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 99,
    this.size = QuantityStepperSize.medium,
    this.gradient,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;
  final QuantityStepperSize size;
  final List<Color>? gradient;

  @override
  State<OrganicQuantityStepper> createState() => _OrganicQuantityStepperState();
}

class _OrganicQuantityStepperState extends State<OrganicQuantityStepper>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  int? _previousValue;
  bool _isIncrementing = true;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.3),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(OrganicQuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animateValueChange(oldWidget.value);
    }
  }

  void _animateValueChange(int oldValue) {
    _previousValue = oldValue;
    _isIncrementing = widget.value > oldValue;

    // Reset controllers to beginning before starting animations
    _slideController.reset();
    _scaleController.reset();

    // Update the slide animation with the correct direction
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _isIncrementing ? const Offset(0, -0.3) : const Offset(0, 0.3),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward().then((_) {
      setState(() => _previousValue = null);
    });

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _increment() {
    if (widget.value < widget.maxValue) {
      HapticFeedback.lightImpact();
      widget.onChanged(widget.value + 1);
    }
  }

  void _decrement() {
    if (widget.value > widget.minValue) {
      HapticFeedback.lightImpact();
      widget.onChanged(widget.value - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradient =
        widget.gradient ?? [AppColors.primaryMain, AppColors.primaryDark];

    final dimensions = _getDimensions(context);

    return Container(
      height: dimensions.height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
        border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            onPressed: _decrement,
            enabled: widget.value > widget.minValue,
            dimensions: dimensions,
            gradient: gradient,
            colorScheme: colorScheme,
          ),
          _buildValueDisplay(dimensions),
          _buildButton(
            icon: Icons.add,
            onPressed: _increment,
            enabled: widget.value < widget.maxValue,
            dimensions: dimensions,
            gradient: gradient,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool enabled,
    required _StepperDimensions dimensions,
    required List<Color> gradient,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: dimensions.buttonWidth,
        height: dimensions.height,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(dimensions.borderRadius - 1),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.38),
          size: dimensions.iconSize,
        ),
      ),
    );
  }

  Widget _buildValueDisplay(_StepperDimensions dimensions) {
    // If no animation is happening, show the value directly without animation
    if (_previousValue == null) {
      return Container(
        width: dimensions.valueWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        child: _buildValueText(widget.value, dimensions.textStyle),
      );
    }

    // Create slide-in animation for new value
    final slideInAnimation = Tween<Offset>(
      begin: _isIncrementing
          ? const Offset(0, 0.3)
          : const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Animate value change
    return Container(
      width: dimensions.valueWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: ReverseAnimation(_slideController),
              child: _buildValueText(_previousValue!, dimensions.textStyle),
            ),
          ),
          SlideTransition(
            position: slideInAnimation,
            child: FadeTransition(
              opacity: _slideController,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildValueText(widget.value, dimensions.textStyle),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueText(int value, TextStyle textStyle) {
    return Text(
      value.toString(),
      style: textStyle,
      textAlign: TextAlign.center,
    );
  }

  _StepperDimensions _getDimensions(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;
    switch (widget.size) {
      case QuantityStepperSize.small:
        return _StepperDimensions(
          height: 36.0,
          buttonWidth: 36.0,
          valueWidth: 40.0,
          borderRadius: 10.0,
          iconSize: 16.0,
          textStyle: AppTypography.buildTextTheme(
            brightness,
          ).titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        );
      case QuantityStepperSize.medium:
        return _StepperDimensions(
          height: 44.0,
          buttonWidth: 44.0,
          valueWidth: 50.0,
          borderRadius: 12.0,
          iconSize: 20.0,
          textStyle: AppTypography.buildTextTheme(
            brightness,
          ).titleLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        );
      case QuantityStepperSize.large:
        return _StepperDimensions(
          height: 52.0,
          buttonWidth: 52.0,
          valueWidth: 60.0,
          borderRadius: 14.0,
          iconSize: 24.0,
          textStyle: AppTypography.buildTextTheme(
            brightness,
          ).headlineSmall!.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        );
    }
  }
}

enum QuantityStepperSize { small, medium, large }

class _StepperDimensions {
  const _StepperDimensions({
    required this.height,
    required this.buttonWidth,
    required this.valueWidth,
    required this.borderRadius,
    required this.iconSize,
    required this.textStyle,
  });

  final double height;
  final double buttonWidth;
  final double valueWidth;
  final double borderRadius;
  final double iconSize;
  final TextStyle textStyle;
}
