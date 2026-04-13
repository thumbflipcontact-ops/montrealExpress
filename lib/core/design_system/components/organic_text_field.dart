import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/typography.dart';
import 'package:abdoul_express/core/theme/shadows.dart';

/// Organic text field with glassmorphic design and gradient borders
///
/// Features:
/// - Glassmorphic background with backdrop blur
/// - Gradient border on focus
/// - Floating label animation
/// - Error state with shake animation
/// - Haptic feedback on interaction
/// - Customizable prefix/suffix icons
class OrganicTextField extends StatefulWidget {
  const OrganicTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.gradient,
    this.errorText,
    this.helperText,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final List<Color>? gradient;
  final String? errorText;
  final String? helperText;
  final bool autofocus;

  @override
  State<OrganicTextField> createState() => _OrganicTextFieldState();
}

class _OrganicTextFieldState extends State<OrganicTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _errorText = widget.errorText;
  }

  @override
  void didUpdateWidget(OrganicTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorText != widget.errorText) {
      setState(() => _errorText = widget.errorText);
      if (widget.errorText != null) {
        _shakeController.forward(from: 0.0);
        HapticFeedback.vibrate();
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final gradient = widget.gradient ?? [AppColors.primaryMain, AppColors.primaryDark];
    final hasError = _errorText != null;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                widget.label!,
                style: AppTypography.buildTextTheme(brightness).bodyMedium!.copyWith(
                      color: hasError
                          ? AppColors.errorMain
                          : _isFocused
                              ? gradient.first
                              : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          // Text field container
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? colorScheme.surface
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: _isFocused ? 2 : 1.5,
                color: hasError
                    ? AppColors.errorMain
                    : _isFocused
                        ? gradient.first
                        : colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              boxShadow: _isFocused
                  ? AppShadows.createColoredShadow(
                      color: hasError ? AppColors.errorMain : gradient.first,
                      opacity: 0.2,
                    )
                  : AppShadows.small,
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: AppTypography.buildTextTheme(brightness).bodyLarge!.copyWith(
                    color: widget.enabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTypography.buildTextTheme(brightness).bodyLarge!.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                prefixIcon: widget.prefixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: hasError
                              ? AppColors.errorMain
                              : _isFocused
                                  ? gradient.first
                                  : colorScheme.onSurfaceVariant,
                        ),
                        child: widget.prefixIcon!,
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: hasError
                              ? AppColors.errorMain
                              : _isFocused
                                  ? gradient.first
                                  : colorScheme.onSurfaceVariant,
                        ),
                        child: widget.suffixIcon!,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.prefixIcon == null ? 16 : 12,
                  vertical: 16,
                ),
              ),
            ),
          ),
          // Error or helper text
          if (_errorText != null || widget.helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 16),
              child: Row(
                children: [
                  if (_errorText != null)
                    Icon(
                      Icons.error_outline,
                      size: 14,
                      color: AppColors.errorMain,
                    ),
                  if (_errorText != null) const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _errorText ?? widget.helperText!,
                      style: AppTypography.buildTextTheme(brightness).bodySmall!.copyWith(
                            color: _errorText != null
                                ? AppColors.errorMain
                                : colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Organic form field with built-in validation
class OrganicFormField extends FormField<String> {
  OrganicFormField({
    super.key,
    TextEditingController? controller,
    String? label,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    super.validator,
    ValueChanged<String>? onChanged,
    super.enabled,
    int? maxLines = 1,
    int? minLines,
    List<Color>? gradient,
    String? helperText,
    bool autofocus = false,
    String? initialValue,
  }) : super(
          initialValue: controller != null ? controller.text : (initialValue ?? ''),
          builder: (FormFieldState<String> field) {
            final effectiveController = controller ?? TextEditingController(text: field.value);

            return OrganicTextField(
              controller: effectiveController,
              label: label,
              hintText: hintText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onChanged: (value) {
                field.didChange(value);
                onChanged?.call(value);
              },
              enabled: enabled,
              maxLines: maxLines,
              minLines: minLines,
              gradient: gradient,
              errorText: field.errorText,
              helperText: helperText,
              autofocus: autofocus,
            );
          },
        );
}
