import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:abdoul_express/core/theme/colors.dart';

/// Organic skeleton loader with shimmer effect matching the design system
/// 
/// Features:
/// - Shimmer animation effect
/// - Organic rounded corners
/// - Brand-compliant colors
/// - Multiple preset layouts for common use cases
class OrganicSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final Color? baseColor;
  final Color? highlightColor;

  const OrganicSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    this.margin = EdgeInsets.zero,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultBaseColor = colorScheme.surfaceContainerHighest;
    final defaultHighlightColor = colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor ?? defaultBaseColor,
      highlightColor: highlightColor ?? defaultHighlightColor,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: baseColor ?? defaultBaseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Product card skeleton for loading states
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          OrganicSkeleton(
            width: double.infinity,
            height: 120,
            borderRadius: 16,
          ),
          const SizedBox(height: 12),
          // Category chip skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OrganicSkeleton(
              width: 60,
              height: 16,
              borderRadius: 8,
            ),
          ),
          const SizedBox(height: 8),
          // Title skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OrganicSkeleton(
              width: double.infinity,
              height: 16,
              borderRadius: 8,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OrganicSkeleton(
              width: 100,
              height: 16,
              borderRadius: 8,
            ),
          ),
          const SizedBox(height: 12),
          // Price skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OrganicSkeleton(
              width: 80,
              height: 20,
              borderRadius: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Product grid skeleton for loading states
class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductGridSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ProductCardSkeleton();
      },
    );
  }
}

/// Category chip skeleton
class CategoryChipSkeleton extends StatelessWidget {
  const CategoryChipSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return OrganicSkeleton(
      width: 80,
      height: 36,
      borderRadius: 18,
    );
  }
}

/// Horizontal list of category skeletons
class CategoryListSkeleton extends StatelessWidget {
  final int itemCount;

  const CategoryListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, __) => const CategoryChipSkeleton(),
      ),
    );
  }
}

/// Cart item skeleton
class CartItemSkeleton extends StatelessWidget {
  const CartItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Image skeleton
          OrganicSkeleton(
            width: 90,
            height: 90,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                OrganicSkeleton(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 8,
                ),
                const SizedBox(height: 8),
                // Category skeleton
                OrganicSkeleton(
                  width: 60,
                  height: 16,
                  borderRadius: 8,
                ),
                const SizedBox(height: 12),
                // Price skeleton
                OrganicSkeleton(
                  width: 80,
                  height: 20,
                  borderRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile header skeleton
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar skeleton
        OrganicSkeleton(
          width: 70,
          height: 70,
          borderRadius: 35,
        ),
        const SizedBox(height: 12),
        // Name skeleton
        OrganicSkeleton(
          width: 150,
          height: 24,
          borderRadius: 8,
        ),
        const SizedBox(height: 4),
        // Email skeleton
        OrganicSkeleton(
          width: 200,
          height: 14,
          borderRadius: 8,
        ),
      ],
    );
  }
}

/// Order card skeleton
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OrganicSkeleton(
                width: 40,
                height: 40,
                borderRadius: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrganicSkeleton(
                      width: 120,
                      height: 16,
                      borderRadius: 8,
                    ),
                    const SizedBox(height: 4),
                    OrganicSkeleton(
                      width: 80,
                      height: 12,
                      borderRadius: 6,
                    ),
                  ],
                ),
              ),
              OrganicSkeleton(
                width: 60,
                height: 24,
                borderRadius: 12,
              ),
            ],
          ),
          const SizedBox(height: 16),
          OrganicSkeleton(
            width: double.infinity,
            height: 1,
            borderRadius: 1,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OrganicSkeleton(
                width: 100,
                height: 14,
                borderRadius: 7,
              ),
              OrganicSkeleton(
                width: 80,
                height: 16,
                borderRadius: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Search result item skeleton
class SearchResultSkeleton extends StatelessWidget {
  const SearchResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: OrganicSkeleton(
        width: 48,
        height: 48,
        borderRadius: 8,
      ),
      title: OrganicSkeleton(
        width: double.infinity,
        height: 16,
        borderRadius: 8,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: OrganicSkeleton(
          width: 100,
          height: 14,
          borderRadius: 7,
        ),
      ),
    );
  }
}

/// Full page loading skeleton for home page
class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header skeleton
        SliverToBoxAdapter(
          child: Container(
            height: 140,
            color: AppColors.primaryMain.withValues(alpha: 0.1),
            child: const Center(
              child: ProfileHeaderSkeleton(),
            ),
          ),
        ),
        // Promo carousel skeleton
        SliverToBoxAdapter(
          child: SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: OrganicSkeleton(
                  width: 280,
                  height: 110,
                  borderRadius: 16,
                ),
              ),
            ),
          ),
        ),
        // Categories skeleton
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CategoryListSkeleton(),
          ),
        ),
        // Product grid skeleton
        const SliverToBoxAdapter(
          child: ProductGridSkeleton(itemCount: 4),
        ),
      ],
    );
  }
}

/// Cart page skeleton
class CartPageSkeleton extends StatelessWidget {
  const CartPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header skeleton
        Container(
          height: 120,
          color: AppColors.primaryMain.withValues(alpha: 0.1),
          child: Center(
            child: OrganicSkeleton(
              width: 150,
              height: 24,
              borderRadius: 12,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: CartItemSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Orders list skeleton
class OrdersListSkeleton extends StatelessWidget {
  const OrdersListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: OrderCardSkeleton(),
      ),
    );
  }
}
