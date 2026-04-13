import 'package:abdoul_express/core/widgets/product_image.dart';
import 'package:abdoul_express/core/app_state.dart';
import 'package:abdoul_express/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abdoul_express/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:abdoul_express/model/product.dart';
import 'package:abdoul_express/features/recently_viewed/data/recently_viewed_service.dart';
import 'package:flutter/material.dart';
import 'package:abdoul_express/core/design_system/painters/blob_clipper.dart';
import 'package:abdoul_express/core/design_system/components/gradient_button.dart';
import 'package:abdoul_express/core/design_system/components/organic_quantity_stepper.dart';
import 'package:abdoul_express/core/design_system/components/organic_toast.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/typography.dart';
import 'package:abdoul_express/core/theme/shadows.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int qty = 1;

  @override
  void initState() {
    super.initState();
    // Add to recently viewed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await RecentlyViewedService.addToRecentlyViewed(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final app = AppState.of(context);
    final isFav = app.isFavorite(p.id);
    final categoryGradient = AppColors.getCategoryGradient(p.category);

    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: AppShadows.small,
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => app.toggleFavorite(p)),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: AppShadows.small,
              ),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppColors.errorMain : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            slivers: [
              // Diagonal clipped image section
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Stack(
                    children: [
                      // Image with diagonal clip
                      ClipPath(
                        clipper: DiagonalClipper(
                          position: DiagonalPosition.bottomLeft,
                          angle: 15,
                        ),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                categoryGradient.first.withValues(alpha: 0.1),
                                categoryGradient.last.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Hero(
                            tag: 'pimg-${p.id}',
                            child: ProductImage(
                              imageUrl: p.imageUrl,
                              assetPath: p.imageAsset,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Price hang tag (positioned outside card)
                      Positioned(
                        right: 20,
                        bottom: 0,
                        child: _buildPriceTag(p.price),
                      ),
                    ],
                  ),
                ),
              ),
              // Overlapping content container
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: AppShadows.large,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: categoryGradient,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppShadows.createColoredShadow(
                                color: categoryGradient.first,
                                opacity: 0.3,
                              ),
                            ),
                            child: Text(
                              p.category,
                              style: AppTypography.categoryChipStyle().copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title and rating
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  p.title,
                                  style:
                                      AppTypography.buildTextTheme(
                                        Brightness.light,
                                      ).headlineMedium!.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildRatingBadge(p.rating),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Description
                          Text(
                            'Description',
                            style:
                                AppTypography.buildTextTheme(
                                  Brightness.light,
                                ).titleMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.description,
                            style:
                                AppTypography.buildTextTheme(
                                  Brightness.light,
                                ).bodyLarge!.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                          ),
                          const SizedBox(height: 24),
                          // Quantity selector
                          Row(
                            children: [
                              Text(
                                'Quantité',
                                style: AppTypography.buildTextTheme(
                                  Brightness.light,
                                ).titleMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              OrganicQuantityStepper(
                                value: qty,
                                onChanged: (v) => setState(() => qty = v),
                                size: QuantityStepperSize.medium,
                                gradient: categoryGradient,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 100,
                          ), // Space for floating buttons
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Floating action buttons at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                boxShadow: AppShadows.large,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlineGradientButton(
                      text: 'Panier',
                      icon: Icons.shopping_bag_outlined,
                      onPressed: () {
                        context.read<CartCubit>().addToCart(
                          CartItem(product: p, quantity: qty),
                        );
                        context.showAddedToCartToast(
                          productName: '${p.title} (x$qty)',
                          onViewCart: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CartPage()),
                            );
                          },
                        );
                      },
                      gradient: categoryGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GradientButton(
                      text: 'Acheter',
                      icon: Icons.arrow_forward,
                      iconPosition: IconPosition.right,
                      onPressed: () {
                        context.read<CartCubit>().addToCart(
                          CartItem(product: p, quantity: qty),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                      gradient: categoryGradient,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTag(double price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryMain, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.primaryColored,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            price.toStringAsFixed(0),
            style: AppTypography.priceStyle(
              color: Colors.white,
            ).copyWith(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          Text(
            'F CFA',
            style: AppTypography.buildTextTheme(Brightness.light).labelSmall!
                .copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.goldAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.goldColored,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.badgeStyle().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
