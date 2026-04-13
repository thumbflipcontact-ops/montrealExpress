import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animation utilities for consistent micro-interactions throughout the app
class AppAnimations {
  AppAnimations._();

  // =============================================================================
  // DURATIONS
  // =============================================================================

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);

  // =============================================================================
  // CURVES
  // =============================================================================

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve smooth = Curves.fastOutSlowIn;

  // =============================================================================
  // STAGGERED ANIMATION HELPERS
  // =============================================================================

  /// Creates a staggered animation delay based on index
  static Duration staggerDelay(int index, {Duration baseDelay = fast}) {
    return Duration(milliseconds: index * baseDelay.inMilliseconds);
  }

  /// Wraps a widget with fade-in and slide animation
  static Widget fadeSlideIn(
    Widget child, {
    int index = 0,
    Duration delay = Duration.zero,
    Offset slideBegin = const Offset(0, 0.3),
  }) {
    final totalDelay = Duration(
      milliseconds: delay.inMilliseconds + (index * 50),
    );

    return child
        .animate()
        .fadeIn(delay: totalDelay, duration: normal)
        .slide(
          begin: slideBegin,
          end: Offset.zero,
          delay: totalDelay,
          duration: normal,
          curve: smooth,
        );
  }

  /// Wraps a widget with scale-in animation
  static Widget scaleIn(
    Widget child, {
    int index = 0,
    Duration delay = Duration.zero,
  }) {
    final totalDelay = Duration(
      milliseconds: delay.inMilliseconds + (index * 50),
    );

    return child
        .animate()
        .fadeIn(delay: totalDelay, duration: normal)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          delay: totalDelay,
          duration: normal,
          curve: elastic,
        );
  }

  /// Wraps a widget with bounce-in animation
  static Widget bounceIn(
    Widget child, {
    int index = 0,
    Duration delay = Duration.zero,
  }) {
    final totalDelay = Duration(
      milliseconds: delay.inMilliseconds + (index * 50),
    );

    return child
        .animate()
        .fadeIn(delay: totalDelay, duration: fast)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          delay: totalDelay,
          duration: slow,
          curve: elastic,
        );
  }

  /// Wraps a widget with slide-in from left animation
  static Widget slideInLeft(
    Widget child, {
    int index = 0,
    Duration delay = Duration.zero,
  }) {
    final totalDelay = Duration(
      milliseconds: delay.inMilliseconds + (index * 50),
    );

    return child
        .animate()
        .fadeIn(delay: totalDelay, duration: normal)
        .slide(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
          delay: totalDelay,
          duration: normal,
          curve: smooth,
        );
  }

  /// Wraps a widget with slide-in from right animation
  static Widget slideInRight(
    Widget child, {
    int index = 0,
    Duration delay = Duration.zero,
  }) {
    final totalDelay = Duration(
      milliseconds: delay.inMilliseconds + (index * 50),
    );

    return child
        .animate()
        .fadeIn(delay: totalDelay, duration: normal)
        .slide(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
          delay: totalDelay,
          duration: normal,
          curve: smooth,
        );
  }

  // =============================================================================
  // INTERACTION ANIMATIONS
  // =============================================================================

  /// Pulse animation for attention
  static Widget pulse(Widget child) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
  }

  /// Shake animation for errors
  static Widget shake(Widget child) {
    return child
        .animate()
        .shake(duration: normal, hz: 5);
  }

  /// Bounce animation for success
  static Widget successBounce(Widget child) {
    return child
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.1, 1.1),
          duration: const Duration(milliseconds: 200),
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 200),
          curve: bounce,
        );
  }

  /// Heart beat animation for favorites
  static Widget heartBeat(Widget child) {
    return child
        .animate()
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.3, 1.3),
          duration: const Duration(milliseconds: 150),
        )
        .then()
        .scale(
          begin: const Offset(1.3, 1.3),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 200),
          curve: elastic,
        );
  }

  /// Rotate animation
  static Widget rotate(Widget child, {double turns = 1}) {
    return child
        .animate()
        .rotate(
          begin: 0,
          end: turns,
          duration: slow,
          curve: smooth,
        );
  }

  // =============================================================================
  // LIST ANIMATIONS
  // =============================================================================

  /// Animates a list of widgets with staggered fade-in
  static List<Widget> staggeredList(
    List<Widget> children, {
    Duration delay = Duration.zero,
    Offset slideBegin = const Offset(0, 0.2),
  }) {
    return children.asMap().entries.map((entry) {
      return fadeSlideIn(
        entry.value,
        index: entry.key,
        delay: delay,
        slideBegin: slideBegin,
      );
    }).toList();
  }

  /// Animates a grid of widgets with staggered scale-in
  static List<Widget> staggeredGrid(
    List<Widget> children, {
    Duration delay = Duration.zero,
  }) {
    return children.asMap().entries.map((entry) {
      return scaleIn(
        entry.value,
        index: entry.key,
        delay: delay,
      );
    }).toList();
  }
}

/// Extension methods for quick animation access
extension WidgetAnimationX on Widget {
  /// Fade in with optional delay
  Widget fadeIn({Duration delay = Duration.zero}) {
    return animate()
        .fadeIn(delay: delay, duration: AppAnimations.normal);
  }

  /// Scale in with bounce
  Widget scaleIn({Duration delay = Duration.zero}) {
    return animate()
        .fadeIn(delay: delay, duration: AppAnimations.fast)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          delay: delay,
          duration: AppAnimations.slow,
          curve: AppAnimations.elastic,
        );
  }

  /// Slide up and fade in
  Widget slideUp({Duration delay = Duration.zero}) {
    return animate()
        .fadeIn(delay: delay, duration: AppAnimations.normal)
        .slide(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
          delay: delay,
          duration: AppAnimations.normal,
          curve: AppAnimations.smooth,
        );
  }

  /// Pulse animation
  Widget pulse() => AppAnimations.pulse(this);

  /// Shake animation
  Widget shake() => AppAnimations.shake(this);

  /// Success bounce
  Widget successBounce() => AppAnimations.successBounce(this);

  /// Heart beat
  Widget heartBeat() => AppAnimations.heartBeat(this);
}
