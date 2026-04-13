import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/shadows.dart';
import 'package:abdoul_express/core/theme/typography.dart';

/// Toast types for different notification styles
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Toast position on screen
enum ToastPosition {
  top,
  center,
  bottom,
}

/// Organic toast notification component
/// 
/// Features:
/// - Multiple toast types (success, error, warning, info)
/// - Position options (top, center, bottom)
/// - Animated entrance/exit
/// - Haptic feedback
/// - Icon support
/// - Action button support
class OrganicToast extends StatelessWidget {
  final String message;
  final String? title;
  final ToastType type;
  final ToastPosition position;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final VoidCallback? onDismiss;

  const OrganicToast({
    super.key,
    required this.message,
    this.title,
    this.type = ToastType.info,
    this.position = ToastPosition.bottom,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final toastTheme = _getToastTheme();

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: toastTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: toastTheme.borderColor,
            width: 1,
          ),
          boxShadow: AppShadows.large,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: toastTheme.iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon ?? toastTheme.defaultIcon,
                color: toastTheme.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: AppTypography.buildTextTheme(Theme.of(context).brightness).titleSmall!.copyWith(
                        color: toastTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message,
                    style: AppTypography.inputStyle(
                      color: toastTheme.textColor.withValues(alpha: 0.9),
                    ),
                  ),
                  if (onAction != null && actionLabel != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onAction!();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        actionLabel!,
                        style: AppTypography.buttonStyle(
                          color: toastTheme.actionColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Dismiss button
            if (onDismiss != null)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: toastTheme.textColor.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDismiss!();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(
          begin: position == ToastPosition.top ? -0.3 : 0.3,
          end: 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
        );
  }

  _ToastTheme _getToastTheme() {
    switch (type) {
      case ToastType.success:
        return _ToastTheme(
          backgroundColor: AppColors.successContainer,
          borderColor: AppColors.successLight,
          iconColor: AppColors.successMain,
          iconBackgroundColor: AppColors.successMain.withValues(alpha: 0.1),
          textColor: AppColors.onSuccessContainer,
          actionColor: AppColors.successDark,
          defaultIcon: Icons.check_circle_outline,
        );
      case ToastType.error:
        return _ToastTheme(
          backgroundColor: AppColors.errorContainer,
          borderColor: AppColors.errorLight,
          iconColor: AppColors.errorMain,
          iconBackgroundColor: AppColors.errorMain.withValues(alpha: 0.1),
          textColor: AppColors.onErrorContainer,
          actionColor: AppColors.errorDark,
          defaultIcon: Icons.error_outline,
        );
      case ToastType.warning:
        return _ToastTheme(
          backgroundColor: AppColors.warningContainer,
          borderColor: AppColors.warningLight,
          iconColor: AppColors.warningMain,
          iconBackgroundColor: AppColors.warningMain.withValues(alpha: 0.1),
          textColor: AppColors.onWarningContainer,
          actionColor: AppColors.warningDark,
          defaultIcon: Icons.warning_amber_outlined,
        );
      case ToastType.info:
        return _ToastTheme(
          backgroundColor: AppColors.infoContainer,
          borderColor: AppColors.infoLight,
          iconColor: AppColors.infoMain,
          iconBackgroundColor: AppColors.infoMain.withValues(alpha: 0.1),
          textColor: AppColors.onInfoContainer,
          actionColor: AppColors.infoDark,
          defaultIcon: Icons.info_outline,
        );
    }
  }
}

class _ToastTheme {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color textColor;
  final Color actionColor;
  final IconData defaultIcon;

  _ToastTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.textColor,
    required this.actionColor,
    required this.defaultIcon,
  });
}

/// Toast service for showing toasts from anywhere in the app
class ToastService {
  ToastService._();

  static final ToastService _instance = ToastService._();
  static ToastService get instance => _instance;

  OverlayEntry? _currentToast;

  /// Show a toast notification
  void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    // Haptic feedback based on type
    switch (type) {
      case ToastType.success:
        HapticFeedback.mediumImpact();
        break;
      case ToastType.error:
        HapticFeedback.heavyImpact();
        break;
      case ToastType.warning:
        HapticFeedback.mediumImpact();
        break;
      case ToastType.info:
        HapticFeedback.lightImpact();
        break;
    }

    // Remove existing toast
    hide();

    final overlay = Overlay.of(context);
    
    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: position == ToastPosition.top
            ? MediaQuery.of(context).padding.top + 16
            : null,
        bottom: position == ToastPosition.bottom ? 100 : null,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Center(
            child: OrganicToast(
              message: message,
              title: title,
              type: type,
              position: position,
              icon: icon,
              onAction: onAction,
              actionLabel: actionLabel,
              onDismiss: hide,
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentToast!);

    // Auto dismiss
    if (duration != Duration.zero) {
      Future.delayed(duration, () {
        hide();
      });
    }
  }

  /// Hide the current toast
  void hide() {
    _currentToast?.remove();
    _currentToast = null;
  }

  /// Show success toast
  void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Succès',
      type: ToastType.success,
      position: position,
      duration: duration,
    );
  }

  /// Show error toast
  void showError(
    BuildContext context, {
    required String message,
    String? title,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Erreur',
      type: ToastType.error,
      position: position,
      duration: duration,
    );
  }

  /// Show warning toast
  void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Attention',
      type: ToastType.warning,
      position: position,
      duration: duration,
    );
  }

  /// Show info toast
  void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastType.info,
      position: position,
      duration: duration,
    );
  }

  /// Show "Added to cart" toast with action
  void showAddedToCart(
    BuildContext context, {
    required String productName,
    VoidCallback? onViewCart,
  }) {
    show(
      context,
      message: 'Ajouté: $productName',
      title: 'Panier mis à jour',
      type: ToastType.success,
      position: ToastPosition.bottom,
      duration: const Duration(seconds: 3),
      icon: Icons.shopping_cart_outlined,
      actionLabel: onViewCart != null ? 'Voir le panier' : null,
      onAction: onViewCart,
    );
  }

  /// Show "Removed from favorites" toast
  void showRemovedFromFavorites(
    BuildContext context, {
    required String productName,
    VoidCallback? onUndo,
  }) {
    show(
      context,
      message: 'Retiré des favoris: $productName',
      type: ToastType.info,
      position: ToastPosition.bottom,
      duration: const Duration(seconds: 3),
      icon: Icons.favorite_border,
      actionLabel: onUndo != null ? 'Annuler' : null,
      onAction: onUndo,
    );
  }

  /// Show "Order placed" toast
  void showOrderPlaced(
    BuildContext context, {
    required String orderNumber,
    VoidCallback? onTrack,
  }) {
    show(
      context,
      message: 'Commande #$orderNumber confirmée',
      title: 'Commande passée!',
      type: ToastType.success,
      position: ToastPosition.bottom,
      duration: const Duration(seconds: 4),
      icon: Icons.check_circle_outline,
      actionLabel: onTrack != null ? 'Suivre' : null,
      onAction: onTrack,
    );
  }
}

/// Extension on BuildContext for easy toast access
extension ToastContextExtension on BuildContext {
  /// Show toast
  void showToast({
    required String message,
    String? title,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    ToastService.instance.show(
      this,
      message: message,
      title: title,
      type: type,
      position: position,
      duration: duration,
    );
  }

  /// Show success toast
  void showSuccessToast({
    required String message,
    String? title,
  }) {
    ToastService.instance.showSuccess(
      this,
      message: message,
      title: title,
    );
  }

  /// Show error toast
  void showErrorToast({
    required String message,
    String? title,
  }) {
    ToastService.instance.showError(
      this,
      message: message,
      title: title,
    );
  }

  /// Show added to cart toast
  void showAddedToCartToast({
    required String productName,
    VoidCallback? onViewCart,
  }) {
    ToastService.instance.showAddedToCart(
      this,
      productName: productName,
      onViewCart: onViewCart,
    );
  }
}
