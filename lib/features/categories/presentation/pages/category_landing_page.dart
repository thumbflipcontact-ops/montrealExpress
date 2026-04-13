import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model/category.dart';
import '../../../../model/product.dart';
import '../../../../core/widgets.dart';
import '../../../../features/products/data/product_repository.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../products/presentation/pages/product_detail_page.dart';
import '../../../search/presentation/pages/search_results_page.dart';
import '../../../../core/app_state.dart';

class CategoryLandingPage extends StatefulWidget {
  final Category category;

  const CategoryLandingPage({super.key, required this.category});

  @override
  State<CategoryLandingPage> createState() => _CategoryLandingPageState();
}

class _CategoryLandingPageState extends State<CategoryLandingPage> {
  final ProductRepository _repo = ProductRepository();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final products = await _repo.getProductsByCategory(
        categoryId: widget.category.id,
      );
      setState(() { _products = products; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image Section
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (category.imageUrl != null)
                    Image.network(
                      category.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).primaryColor.withValues(alpha: 0.7),
                              Theme.of(context).primaryColor.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).primaryColor.withValues(alpha: 0.7),
                            Theme.of(context).primaryColor.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${category.productCount} produits disponibles',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SearchResultsPage(initialQuery: category.name),
                    ),
                  );
                },
              ),
            ],
          ),

          // Category Description
          if (category.description != null && category.description!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  category.description!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),

          // Subcategories Section
          if (category.subcategories.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Sous-catégories',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: category.subcategories.length,
                      itemBuilder: (context, index) {
                        final subcategory = category.subcategories[index];
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () {
                              // TODO: navigate to subcategory products
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.category,
                                      size: 40,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  subcategory.name,
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${subcategory.productCount}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // Products header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Produits',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),

          // Loading / Error / Products Grid
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('Erreur: $_error', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          else if (_products.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Aucun produit dans cette catégorie')),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _products[index];
                    final favoritesCubit = context.watch<FavoritesCubit>();
                    final isFav = favoritesCubit.isFavorite(product.id);
                    return ProductCard(
                      product: product,
                      isFavorite: isFav,
                      onFavToggle: () =>
                          favoritesCubit.toggleFavorite(product),
                      onAddToCart: () =>
                          context.read<CartCubit>().addToCart(
                                CartItem(product: product, quantity: 1),
                              ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(product: product),
                        ),
                      ),
                    );
                  },
                  childCount: _products.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

/// Full-screen product listing for a subcategory (uses real API via category ID)
class SubcategoryProductsPage extends StatefulWidget {
  final Subcategory subcategory;
  final String categoryName;

  const SubcategoryProductsPage({
    super.key,
    required this.subcategory,
    required this.categoryName,
  });

  @override
  State<SubcategoryProductsPage> createState() =>
      _SubcategoryProductsPageState();
}

class _SubcategoryProductsPageState extends State<SubcategoryProductsPage> {
  final ProductRepository _repo = ProductRepository();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final products = await _repo.getProductsByCategory(
        categoryId: widget.subcategory.id,
      );
      setState(() { _products = products; _isLoading = false; });
    } catch (_) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subcategory.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ProductCard(
                  product: product,
                  isFavorite: false,
                  onFavToggle: () =>
                      context.read<FavoritesCubit>().toggleFavorite(product),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: product),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// All products in a category (used from "Voir tout" button)
class CategoryProductsPage extends StatefulWidget {
  final Category category;

  const CategoryProductsPage({super.key, required this.category});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final ProductRepository _repo = ProductRepository();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final products = await _repo.getProductsByCategory(
        categoryId: widget.category.id,
      );
      setState(() { _products = products; _isLoading = false; });
    } catch (_) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ProductCard(
                  product: product,
                  isFavorite: false,
                  onFavToggle: () =>
                      context.read<FavoritesCubit>().toggleFavorite(product),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: product),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
