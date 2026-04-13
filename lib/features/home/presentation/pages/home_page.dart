import 'package:abdoul_express/core/widgets.dart';
import 'package:abdoul_express/core/app_state.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/design_system/painters/geometric_pattern_painter.dart';
import 'package:abdoul_express/core/design_system/components/guest_banner.dart';
import 'package:abdoul_express/core/design_system/components/organic_skeleton.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abdoul_express/features/products/presentation/bloc/products_cubit.dart';
import 'package:abdoul_express/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:abdoul_express/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:abdoul_express/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:abdoul_express/features/auth/presentation/cubit/auth_state.dart';
import 'package:abdoul_express/features/products/presentation/pages/product_detail_page.dart';
import 'package:abdoul_express/features/search/presentation/pages/search_results_page.dart';
import 'package:abdoul_express/features/categories/presentation/pages/categories_overview_page.dart';
import 'package:abdoul_express/features/promotions/presentation/pages/special_offers_page.dart';
import 'package:abdoul_express/features/new_arrivals/presentation/pages/new_arrivals_page.dart';
import 'package:abdoul_express/features/recently_viewed/presentation/widgets/recently_viewed_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selected = 'Tous';
  final String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const HomePageSkeleton();
        }

        if (state.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error ?? 'Une erreur est survenue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProductsCubit>().loadProducts(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final allProducts = state.products;
        final categories = {'Tous'}..addAll(allProducts.map((p) => p.category));
        var products = _selected == 'Tous'
            ? allProducts
            : allProducts.where((p) => p.category == _selected).toList();

        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          products = products.where((p) {
            return p.title.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query);
          }).toList();
        }

        return CustomScrollView(
          slivers: [
            // Compact header
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 140,
              backgroundColor: AppColors.primaryMain,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate if app bar is collapsed
                  final double appBarHeight = constraints.maxHeight;
                  final double collapsedHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
                  final bool isCollapsed = appBarHeight <= collapsedHeight + 20;

                  return FlexibleSpaceBar(
                    titlePadding: EdgeInsets.zero,
                    title: isCollapsed
                        ? SafeArea(
                            child: SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                children: [
                                  ...categories.map((category) {
                                    final isSelected = _selected == category;
                                    final gradient = [AppColors.primaryMain, AppColors.primaryDark];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: InkWell(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() => _selected = category);
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            gradient: isSelected ? LinearGradient(colors: gradient) : null,
                                            color: isSelected ? null : Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  _CompactIconButton(
                                    icon: Icons.local_offer,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SpecialOffersPage(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  _CompactIconButton(
                                    icon: Icons.notifications_none,
                                    onTap: () {},
                                    showBadge: true,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : null,
                    background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryLight, AppColors.primaryMain],
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: GeometricPatternPainter(
                          color: Colors.white,
                          opacity: 0.08,
                          spacing: 60,
                          patternType: PatternType.circles,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'AbdoulExpress',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 20 : 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Row(
                                  children: [
                                    BlocBuilder<AuthCubit, AuthState>(
                                      builder: (context, authState) {
                                        if (authState is AuthAuthenticated && authState.isGuest) {
                                          return const GuestBadge();
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                    _CompactIconButton(
                                      icon: Icons.local_offer,
                                      onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const SpecialOffersPage())),
                                    ),
                                    const SizedBox(width: 8),
                                    _CompactIconButton(
                                      icon: Icons.notifications_none,
                                      onTap: () {},
                                      showBadge: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Compact search field
                            Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: TextField(
                                onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const SearchResultsPage())),
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Rechercher...',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: AppColors.primaryMain,
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                  );
                },
              ),
            ),

            // Guest banner (if user is in guest mode)
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated && authState.isGuest) {
                  return const SliverToBoxAdapter(
                    child: GuestBanner(),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            // Compact promotion carousel
            SliverToBoxAdapter(
              child: SizedBox(
                height: 130,
                child: PageView(
                  controller: PageController(viewportFraction: 0.9),
                  children: const [
                    _CompactPromoCard(
                      gradient: [Color(0xFF6B7B5B), Color(0xFF4A5940)],
                      title: 'Vente Flash',
                      discount: '-50%',
                      icon: Icons.flash_on,
                    ),
                    _CompactPromoCard(
                      gradient: [Color(0xFF5B8DB8), Color(0xFF3D5E7A)],
                      title: 'High-Tech',
                      discount: '-30%',
                      icon: Icons.devices,
                    ),
                    _CompactPromoCard(
                      gradient: [Color(0xFFD45D42), Color(0xFFA83E2A)],
                      title: 'Mode Été',
                      discount: '-20%',
                      icon: Icons.checkroom,
                    ),
                  ],
                ),
              ),
            ),

            // Recently viewed - more compact
            const SliverToBoxAdapter(child: RecentlyViewedCarousel()),

            // Compact categories - single line
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Catégories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: categories.map((category) {
                    final isSelected = category == _selected;
                    final gradient = AppColors.getCategoryGradient(category);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = category);
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(colors: gradient)
                                : null,
                            color: isSelected ? null : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : colorScheme.onSurface,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Compact action buttons
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    _CompactActionButton(
                      icon: Icons.category,
                      label: 'Catégories',
                      color: AppColors.primaryMain,
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => CategoriesOverviewPage())),
                    ),
                    const SizedBox(width: 8),
                    _CompactActionButton(
                      icon: Icons.local_offer,
                      label: 'Promotions',
                      color: AppColors.errorMain,
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SpecialOffersPage())),
                    ),
                    const SizedBox(width: 8),
                    _CompactActionButton(
                      icon: Icons.new_releases,
                      label: 'Nouveautés',
                      color: AppColors.successMain,
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const NewArrivalsPage())),
                    ),
                  ],
                ),
              ),
            ),

            // Product grid with staggered animations
            SliverPadding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 3 : 2,
                  mainAxisSpacing: isTablet ? 12 : 10,
                  crossAxisSpacing: isTablet ? 12 : 10,
                  childAspectRatio: isTablet ? 0.8 : 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = products[index];
                    final favoritesCubit = context.watch<FavoritesCubit>();
                    final isFav = favoritesCubit.isFavorite(p.id);
                    return ProductCard(
                      product: p,
                      isFavorite: isFav,
                      onFavToggle: () => context.read<FavoritesCubit>().toggleFavorite(p),
                      onAddToCart: () => context.read<CartCubit>().addToCart(
                        CartItem(product: p, quantity: 1),
                      ),
                      onTap: () => Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              ProductDetailsPage(product: p),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                              FadeTransition(opacity: animation, child: child),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: (50 * index).ms,
                        )
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 400.ms,
                          delay: (50 * index).ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                  childCount: products.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Compact icon button
class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            if (showBadge)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.errorMain,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Compact promo card
class _CompactPromoCard extends StatelessWidget {
  const _CompactPromoCard({
    required this.gradient,
    required this.title,
    required this.discount,
    required this.icon,
  });

  final List<Color> gradient;
  final String title;
  final String discount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DEALS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    discount,
                    style: TextStyle(
                      color: gradient.last,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// Compact action button
class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
