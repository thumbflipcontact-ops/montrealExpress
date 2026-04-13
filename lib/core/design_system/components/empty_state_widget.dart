import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/typography.dart';
import 'package:abdoul_express/core/design_system/components/gradient_button.dart';

/// Reusable empty state widget with illustration and action
/// Features:
/// - Animated icon with bounce effect
/// - Organic gradient background
/// - Brand-compliant styling
/// - Support for custom illustrations
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.illustration,
    this.actionText,
    this.onActionPressed,
    this.secondaryActionText,
    this.onSecondaryActionPressed,
    this.iconBackgroundGradient,
    this.iconColor,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? illustration;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryActionPressed;
  final List<Color>? iconBackgroundGradient;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration or animated icon
            if (illustration != null)
              illustration!
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
            else if (icon != null)
              _buildAnimatedIcon(),

            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: AppTypography.buildTextTheme(Theme.of(context).brightness)
                  .headlineSmall!
                  .copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 400.ms),

            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: AppTypography.buildTextTheme(Theme.of(context).brightness)
                    .bodyLarge!
                    .copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
            ],

            const SizedBox(height: 32),

            // Primary action
            if (actionText != null && onActionPressed != null)
              GradientButton(
                text: actionText!,
                onPressed: onActionPressed,
                isExpanded: false,
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, duration: 400.ms),

            // Secondary action
            if (secondaryActionText != null && onSecondaryActionPressed != null) ...[
              const SizedBox(height: 12),
              OutlineGradientButton(
                text: secondaryActionText!,
                onPressed: onSecondaryActionPressed,
                isExpanded: false,
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    final gradient = iconBackgroundGradient ?? [
      AppColors.primaryLight.withValues(alpha: 0.3),
      AppColors.primaryMain.withValues(alpha: 0.1),
    ];
    final iconClr = iconColor ?? AppColors.primaryMain;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (iconBackgroundGradient?.first ?? AppColors.primaryMain)
                .withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 56,
        color: iconClr,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 2000.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1, 1),
          duration: 2000.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Pre-built empty states for common scenarios
class EmptyStates {
  EmptyStates._();

  /// Empty cart state
  static Widget emptyCart({VoidCallback? onBrowseProducts}) {
    return EmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: 'Votre panier est vide',
      subtitle: 'Explorez nos produits et ajoutez-en à votre panier!',
      actionText: 'Découvrir les produits',
      onActionPressed: onBrowseProducts,
      iconBackgroundGradient: [
        AppColors.primaryLight.withValues(alpha: 0.3),
        AppColors.primaryMain.withValues(alpha: 0.1),
      ],
      iconColor: AppColors.primaryMain,
    );
  }

  /// No search results
  static Widget noSearchResults({
    required String query,
    VoidCallback? onClearSearch,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Aucun résultat trouvé',
      subtitle: 'Nous n\'avons trouvé aucun produit pour "$query"',
      actionText: 'Effacer la recherche',
      onActionPressed: onClearSearch,
      iconBackgroundGradient: [
        AppColors.infoLight.withValues(alpha: 0.3),
        AppColors.infoMain.withValues(alpha: 0.1),
      ],
      iconColor: AppColors.infoMain,
    );
  }

  /// No favorites
  static Widget noFavorites({VoidCallback? onBrowseProducts}) {
    return EmptyStateWidget(
      icon: Icons.favorite_border,
      title: 'Aucun favori',
      subtitle: 'Ajoutez des produits à vos favoris pour les retrouver facilement',
      actionText: 'Parcourir les produits',
      onActionPressed: onBrowseProducts,
      iconBackgroundGradient: [
        AppColors.errorLight.withValues(alpha: 0.3),
        AppColors.errorMain.withValues(alpha: 0.1),
      ],
      iconColor: AppColors.errorMain,
    );
  }

  /// No orders
  static Widget noOrders({VoidCallback? onStartShopping}) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'Aucune commande',
      subtitle: 'Vous n\'avez pas encore passé de commande',
      actionText: 'Commencer mes achats',
      onActionPressed: onStartShopping,
      iconBackgroundGradient: [
        AppColors.secondaryLight.withValues(alpha: 0.3),
        AppColors.secondaryMain.withValues(alpha: 0.1),
      ],
      iconColor: AppColors.secondaryDark,
    );
  }

  /// No addresses
  static Widget noAddresses({VoidCallback? onAddAddress}) {
    return EmptyStateWidget(
      icon: Icons.location_on_outlined,
      title: 'Aucune adresse',
      subtitle: 'Ajoutez une adresse de livraison pour vos commandes',
      actionText: 'Ajouter une adresse',
      onActionPressed: onAddAddress,
      iconBackgroundGradient: [
        AppColors.tertiaryLight.withValues(alpha: 0.3),
        AppColors.tertiaryMain.withValues(alpha: 0.1),
      ],
      iconColor: AppColors.tertiaryMain,
    );
  }

  /// Network error
  static Widget networkError({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'Erreur de connexion',
      subtitle: 'Vérifiez votre connexion Internet et réessayez',
      actionText: 'Réessayer',
      onActionPressed: onRetry,
      iconBackgroundGradient: [
        AppColors.warningLight.withValues(alpha: 0.3),
        AppColors.warningMain.withValues(alpha: 0.1),
      ],
      iconColor: AppColors.warningMain,
    );
  }

  /// Generic error
  static Widget error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Une erreur s\'est produite',
      subtitle: message ?? 'Veuillez réessayer plus tard',
      actionText: 'Réessayer',
      onActionPressed: onRetry,
      iconBackgroundGradient: [
        AppColors.errorLight.withValues(alpha: 0.3),
        AppColors.errorMain.withValues(alpha: 0.1),
      ],
      iconColor: AppColors.errorMain,
    );
  }

  /// Coming soon
  static Widget comingSoon() {
    return EmptyStateWidget(
      icon: Icons.schedule,
      title: 'Bientôt disponible',
      subtitle: 'Cette fonctionnalité sera disponible prochainement',
      iconBackgroundGradient: [
        AppColors.goldLight.withValues(alpha: 0.3),
        AppColors.goldAccent.withValues(alpha: 0.1),
      ],
      iconColor: AppColors.goldDark,
    );
  }

  /// Empty notifications
  static Widget noNotifications() {
    return EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'Aucune notification',
      subtitle: 'Vous recevrez ici les mises à jour de vos commandes',
      iconBackgroundGradient: [
        AppColors.infoLight.withValues(alpha: 0.3),
        AppColors.infoMain.withValues(alpha: 0.1),
      ],
      iconColor: AppColors.infoMain,
    );
  }

  /// Empty chat
  static Widget noMessages({VoidCallback? onStartChat}) {
    return EmptyStateWidget(
      icon: Icons.chat_bubble_outline,
      title: 'Aucun message',
      subtitle: 'Commencez une conversation avec notre équipe',
      actionText: 'Nouveau message',
      onActionPressed: onStartChat,
      iconBackgroundGradient: [
        AppColors.secondaryLight.withValues(alpha: 0.3),
        AppColors.secondaryMain.withValues(alpha: 0.1),
      ],
      iconColor: AppColors.secondaryDark,
    );
  }
}
