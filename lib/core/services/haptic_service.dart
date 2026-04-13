import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized haptic feedback service
/// 
/// Provides consistent haptic feedback throughout the app
/// for different user interactions.
class HapticService {
  HapticService._();

  static final HapticService _instance = HapticService._();
  static HapticService get instance => _instance;

  bool _enabled = true;

  /// Whether haptic feedback is enabled
  bool get isEnabled => _enabled;

  /// Enable or disable haptic feedback
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Light impact - for subtle feedback like taps on buttons
  static void lightImpact() {
    if (_instance._enabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Medium impact - for more significant actions
  static void mediumImpact() {
    if (_instance._enabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Heavy impact - for important actions
  static void heavyImpact() {
    if (_instance._enabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Selection click - for selection changes
  static void selectionClick() {
    if (_instance._enabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// Success - pattern for successful actions
  static Future<void> success() async {
    if (!_instance._enabled) return;
    
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error - pattern for error states
  static Future<void> error() async {
    if (!_instance._enabled) return;
    
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Warning - pattern for warnings
  static Future<void> warning() async {
    if (!_instance._enabled) return;
    
    await HapticFeedback.mediumImpact();
  }

  /// Button press - standard button feedback
  static void buttonPress() {
    lightImpact();
  }

  /// Toggle switch - feedback for toggles
  static void toggle() {
    selectionClick();
  }

  /// Scroll tick - feedback for scroll snapping
  static void scrollTick() {
    selectionClick();
  }

  /// Long press - feedback for long press actions
  static void longPress() {
    mediumImpact();
  }

  /// Delete/Remove - feedback for destructive actions
  static void delete() {
    heavyImpact();
  }

  /// Added to cart - feedback for cart actions
  static Future<void> addedToCart() async {
    if (!_instance._enabled) return;
    
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Checkout success - feedback for purchase completion
  static Future<void> checkoutSuccess() async {
    if (!_instance._enabled) return;
    
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Favorite toggle - feedback for favorite actions
  static void favorite() {
    mediumImpact();
  }

  /// Refresh/pull - feedback for refresh actions
  static void refresh() {
    mediumImpact();
  }

  /// Page change - feedback for page navigation
  static void pageChange() {
    lightImpact();
  }

  /// Drag start - feedback when starting a drag
  static void dragStart() {
    lightImpact();
  }

  /// Drag end - feedback when ending a drag
  static void dragEnd() {
    lightImpact();
  }

  /// Snap to position - feedback for drag snapping
  static void snap() {
    mediumImpact();
  }
}

/// Extension on Widget to easily add haptic feedback to gestures
extension HapticGestureExtension on GestureDetector {
  /// Wraps the onTap with light impact haptic
  GestureDetector withLightHaptic({
    Key? key,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap != null
          ? () {
              HapticService.lightImpact();
              onTap();
            }
          : null,
      child: child,
    );
  }

  /// Wraps the onTap with medium impact haptic
  GestureDetector withMediumHaptic({
    Key? key,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap != null
          ? () {
              HapticService.mediumImpact();
              onTap();
            }
          : null,
      child: child,
    );
  }
}
