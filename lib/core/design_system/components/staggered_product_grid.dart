import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:abdoul_express/core/design_system/components/organic_product_card.dart';
import 'package:abdoul_express/model/product.dart';

/// Staggered masonry grid for organic product layout
/// Cards have varying heights for asymmetric, hand-placed feel
class StaggeredProductGrid extends StatelessWidget {
  const StaggeredProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onFavoriteToggle,
    this.onAddToCart,
    this.favoriteIds = const {},
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.minHeight = 240.0,
    this.maxHeight = 320.0,
  });

  final List<Product> products;
  final Function(Product) onProductTap;
  final Function(Product)? onFavoriteToggle;
  final Function(Product)? onAddToCart;
  final Set<String> favoriteIds;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets padding;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: padding,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        // Vary heights for organic feel
        final height = _calculateCardHeight(product);

        return OrganicProductCard(
          product: product,
          height: height,
          onTap: () => onProductTap(product),
          onFavoriteToggle: onFavoriteToggle != null
              ? () => onFavoriteToggle!(product)
              : null,
          onAddToCart: onAddToCart != null
              ? () => onAddToCart!(product)
              : null,
          isFavorite: favoriteIds.contains(product.id),
        );
      },
    );
  }

  /// Calculate card height based on product properties
  /// Creates varied heights for organic staggered layout
  double _calculateCardHeight(Product product) {
    // Use product ID hash for consistent but varied heights
    final random = math.Random(product.id.hashCode);

    // Generate height between min and max
    final range = maxHeight - minHeight;
    final randomValue = random.nextDouble();

    return minHeight + (range * randomValue);
  }
}

/// Sliver variant of staggered grid for use in CustomScrollView
class SliverStaggeredProductGrid extends StatelessWidget {
  const SliverStaggeredProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onFavoriteToggle,
    this.onAddToCart,
    this.favoriteIds = const {},
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.minHeight = 240.0,
    this.maxHeight = 320.0,
  });

  final List<Product> products;
  final Function(Product) onProductTap;
  final Function(Product)? onFavoriteToggle;
  final Function(Product)? onAddToCart;
  final Set<String> favoriteIds;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        // Vary heights for organic feel
        final height = _calculateCardHeight(product);

        return OrganicProductCard(
          product: product,
          height: height,
          onTap: () => onProductTap(product),
          onFavoriteToggle: onFavoriteToggle != null
              ? () => onFavoriteToggle!(product)
              : null,
          onAddToCart: onAddToCart != null
              ? () => onAddToCart!(product)
              : null,
          isFavorite: favoriteIds.contains(product.id),
        );
      },
    );
  }

  /// Calculate card height based on product properties
  double _calculateCardHeight(Product product) {
    final random = math.Random(product.id.hashCode);
    final range = maxHeight - minHeight;
    final randomValue = random.nextDouble();
    return minHeight + (range * randomValue);
  }
}
