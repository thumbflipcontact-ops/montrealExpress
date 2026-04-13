import 'package:abdoul_express/core/widgets/product_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abdoul_express/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:abdoul_express/core/design_system/components/empty_state_widget.dart';
import 'package:abdoul_express/core/design_system/components/gradient_button.dart';
import 'package:abdoul_express/core/design_system/components/organic_quantity_stepper.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/typography.dart';
import 'package:abdoul_express/core/theme/shadows.dart';
import 'package:abdoul_express/core/app_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import '../../../../root_shell.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('🛍️ [CartPage] $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    _logDebug('build() called');
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (previous, current) {
        final shouldRebuild = previous != current;
        _logDebug(
          'buildWhen: previous=${previous.items.length} items, current=${current.items.length} items, shouldRebuild=$shouldRebuild',
        );
        if (shouldRebuild) {
          _logDebug(
            'State changed! Previous props: ${previous.props}, Current props: ${current.props}',
          );
        }
        return shouldRebuild;
      },
      builder: (context, state) {
        final items = state.items;
        final subtotal = items.fold<double>(
          0,
          (sum, item) => sum + (item.product.price * item.quantity),
        );
        final shipping = items.isEmpty ? 0.0 : 1000.0;
        final total = subtotal + shipping;

        _logDebug(
          'Building cart page: ${items.length} items, subtotal: ${subtotal.toStringAsFixed(0)} F CFA',
        );

        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Column(
            children: [
              // Gradient header with cart count
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryMain,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // AppBar
                      SizedBox(
                        height: 56,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      // Title and count
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            Text(
                              'Mon Panier',
                              style: AppTypography.buildTextTheme(Brightness.dark)
                                  .headlineMedium!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (items.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${items.length} ${items.length == 1 ? "article" : "articles"}',
                                  style: AppTypography.badgeStyle().copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Scrollable product list
              Expanded(
                child: items.isEmpty
                    ? EmptyStates.emptyCart(
                        onBrowseProducts: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const RootShell()),
                            (route) => false,
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final it = items[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _OrganicCartItemCard(
                              item: it,
                              onQuantityChange: (v) {
                                context.read<CartCubit>().setQuantity(it.product.id, v);
                              },
                              onRemove: () {
                                context.read<CartCubit>().removeFromCart(it.product.id);
                              },
                            ),
                          )
                              .animate()
                              .fadeIn(
                                duration: 300.ms,
                                delay: (50 * i).ms,
                              )
                              .slideX(
                                begin: 0.1,
                                end: 0,
                                duration: 300.ms,
                                delay: (50 * i).ms,
                                curve: Curves.easeOutCubic,
                              );
                        },
                      ),
              ),
              // Fixed bottom section (summary + checkout button)
              if (items.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.1),
                        offset: const Offset(0, -4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Summary rows
                          _buildSummaryRow('Sous-total', subtotal, colorScheme),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Livraison', shipping, colorScheme),
                          const SizedBox(height: 16),
                          // Divider
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryMain.withValues(alpha: 0.1),
                                  AppColors.primaryMain.withValues(alpha: 0.5),
                                  AppColors.primaryMain.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Total
                          Row(
                            children: [
                              Text(
                                'Total',
                                style: AppTypography.buildTextTheme(Brightness.light)
                                    .titleLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                '${total.toStringAsFixed(0)} F CFA',
                                style: AppTypography.priceStyle(color: AppColors.primaryMain).copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Checkout button
                          GradientButton(
                            text: 'Passer au paiement',
                            icon: Icons.lock,
                            onPressed: () {
                              _logDebug('User clicked checkout. Total: ${total.toStringAsFixed(0)} F CFA');
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CheckoutPage()),
                              );
                            },
                            gradient: [AppColors.primaryMain, AppColors.primaryDark],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, double value, ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.buildTextTheme(Brightness.light).bodyLarge!.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        Text(
          '${value.toStringAsFixed(0)} F CFA',
          style: AppTypography.buildTextTheme(Brightness.light).bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}

// Organic cart item card with asymmetric layout
class _OrganicCartItemCard extends StatelessWidget {
  const _OrganicCartItemCard({
    required this.item,
    required this.onQuantityChange,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryGradient = AppColors.getCategoryGradient(item.product.category);
    final seed = item.product.id.hashCode;

    // Slight rotation for organic feel
    final rotation = ((seed % 200) - 100) / 200.0; // -0.5 to +0.5 degrees

    return Transform.rotate(
      angle: rotation * math.pi / 180,
      child: Dismissible(
        key: Key(item.product.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.errorLight, AppColors.errorMain],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
        ),
        onDismissed: (_) => onRemove(),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20 + (seed % 4).toDouble()),
              topRight: Radius.circular(16 + (seed % 3).toDouble()),
              bottomLeft: Radius.circular(16 + (seed % 5).toDouble()),
              bottomRight: Radius.circular(20 + (seed % 6).toDouble()),
            ),
            boxShadow: AppShadows.createColoredShadow(
              color: categoryGradient.first,
              opacity: 0.15,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image with gradient overlay
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          categoryGradient.first.withValues(alpha: 0.1),
                          categoryGradient.last.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: ProductImage(
                      imageUrl: item.product.imageUrl,
                      assetPath: item.product.imageAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.buildTextTheme(Brightness.light)
                            .titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 6),
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: categoryGradient),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.product.category,
                          style: AppTypography.categoryChipStyle().copyWith(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Price
                      Text(
                        '${item.product.price.toStringAsFixed(0)} F CFA',
                        style: AppTypography.priceStyle(color: AppColors.primaryMain)
                            .copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      // Quantity stepper
                      OrganicQuantityStepper(
                        value: item.quantity,
                        onChanged: onQuantityChange,
                        size: QuantityStepperSize.small,
                        gradient: categoryGradient,
                      ),
                    ],
                  ),
                ),
                // Delete button
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onRemove,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.errorMain,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
