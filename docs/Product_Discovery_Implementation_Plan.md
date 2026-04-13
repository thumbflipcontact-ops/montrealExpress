# Product Discovery & Experience Implementation Plan
## AbdoulExpress E-commerce App

### Overview
This document provides a detailed implementation plan for enhancing the product discovery experience in AbdoulExpress. The focus is on creating intuitive, efficient, and engaging ways for users to explore products.

---

## 1. Search Results Page with Filters and Sorting

### 1.1 Create Search Feature Structure

#### File: `lib/features/search/presentation/cubit/search_cubit.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/product.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState.initial());

  void searchProducts(String query) {
    emit(state.copyWith(isLoading: true));

    // Simulate API call
    Future.delayed(Duration(milliseconds: 500), () {
      final results = mockProducts.where((product) {
        return product.title.toLowerCase().contains(query.toLowerCase()) ||
               product.description.toLowerCase().contains(query.toLowerCase());
      }).toList();

      emit(state.copyWith(
        isLoading: false,
        products: results,
        query: query,
      ));
    });
  }

  void updateFilters(SearchFilters filters) {
    emit(state.copyWith(filters: filters));
    _applyFilters();
  }

  void setSortOrder(SortOrder order) {
    emit(state.copyWith(sortOrder: order));
    _applySorting();
  }

  void _applyFilters() {
    var filtered = state.allProducts;

    if (state.filters.categories.isNotEmpty) {
      filtered = filtered.where((p) => state.filters.categories.contains(p.category)).toList();
    }

    if (state.filters.priceRange != null) {
      final range = state.filters.priceRange!;
      filtered = filtered.where((p) => p.price >= range.start && p.price <= range.end).toList();
    }

    if (state.filters.minRating != null) {
      filtered = filtered.where((p) => p.rating >= state.filters.minRating!).toList();
    }

    emit(state.copyWith(products: filtered));
  }

  void _applySorting() {
    var sorted = List<Product>.from(state.products);

    switch (state.sortOrder) {
      case SortOrder.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOrder.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOrder.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOrder.newest:
        // Would need creation date in Product model
        sorted = List.from(sorted.reversed);
        break;
      case SortOrder.relevance:
      default:
        // Keep original order
        break;
    }

    emit(state.copyWith(products: sorted));
  }
}

class SearchState {
  final bool isLoading;
  final List<Product> products;
  final List<Product> allProducts;
  final String query;
  final SearchFilters filters;
  final SortOrder sortOrder;

  SearchState({
    required this.isLoading,
    required this.products,
    required this.allProducts,
    required this.query,
    required this.filters,
    required this.sortOrder,
  });

  factory SearchState.initial() {
    return SearchState(
      isLoading: false,
      products: [],
      allProducts: mockProducts,
      query: '',
      filters: SearchFilters(),
      sortOrder: SortOrder.relevance,
    );
  }

  SearchState copyWith({
    bool? isLoading,
    List<Product>? products,
    List<Product>? allProducts,
    String? query,
    SearchFilters? filters,
    SortOrder? sortOrder,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class SearchFilters {
  final List<String> categories;
  final RangeValues? priceRange;
  final double? minRating;

  SearchFilters({
    this.categories = const [],
    this.priceRange,
    this.minRating,
  });
}

enum SortOrder {
  relevance,
  priceLowToHigh,
  priceHighToLow,
  rating,
  newest,
}
```

#### File: `lib/features/search/presentation/pages/search_results_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/search_cubit.dart';
import '../../../core/widgets.dart';
import '../../../model/product.dart';
import '../../products/presentation/pages/product_detail_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({required this.query});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchCubit>().searchProducts(widget.query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: SearchBar(
              initialValue: widget.query,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context.read<SearchCubit>().searchProducts(value);
                }
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          PopupMenuButton<SortOrder>(
            icon: Icon(Icons.sort),
            onSelected: (order) {
              context.read<SearchCubit>().setSortOrder(order);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: SortOrder.relevance, child: Text('Pertinence')),
              PopupMenuItem(value: SortOrder.priceLowToHigh, child: Text('Prix croissant')),
              PopupMenuItem(value: SortOrder.priceHighToLow, child: Text('Prix décroissant')),
              PopupMenuItem(value: SortOrder.rating, child: Text('Note')),
              PopupMenuItem(value: SortOrder.newest, child: Text('Nouveautés')),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          // Filters Sidebar
          if (_showFilters)
            Container(
              width: 300,
              color: Theme.of(context).colorScheme.surface,
              child: _buildFiltersPanel(),
            ),

          // Results
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return _buildLoadingState();
                }

                if (state.products.isEmpty && state.query.isNotEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    // Results Header
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            '${state.products.length} résultats',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Spacer(),
                          if (state.filters.categories.isNotEmpty ||
                              state.filters.priceRange != null)
                            TextButton(
                              child: Text('Effacer les filtres'),
                              onPressed: () {
                                context.read<SearchCubit>().updateFilters(SearchFilters());
                              },
                            ),
                        ],
                      ),
                    ),

                    // Active Filters Chips
                    if (state.filters.categories.isNotEmpty)
                      Container(
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: state.filters.categories.map((category) {
                            return Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(category),
                                deleteIcon: Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  final newCategories = List<String>.from(state.filters.categories)
                                    ..remove(category);
                                  context.read<SearchCubit>().updateFilters(
                                    state.filters.copyWith(categories: newCategories),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    // Product Grid
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _showFilters ? 2 : 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return ProductCard(
                            product: product,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsPage(product: product),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Categories Filter
            Text('Catégories', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            ...categories.map((category) {
              final isSelected = state.filters.categories.contains(category);
              return CheckboxListTile(
                title: Text(category),
                value: isSelected,
                onChanged: (value) {
                  final newCategories = List<String>.from(state.filters.categories);
                  if (value!) {
                    newCategories.add(category);
                  } else {
                    newCategories.remove(category);
                  }
                  context.read<SearchCubit>().updateFilters(
                    state.filters.copyWith(categories: newCategories),
                  );
                },
              );
            }).toList(),

            SizedBox(height: 24),

            // Price Range Filter
            Text('Prix', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            RangeSlider(
              values: state.filters.priceRange ?? RangeValues(0, 50000),
              min: 0,
              max: 50000,
              divisions: 20,
              labels: RangeLabels(
                '${state.filters.priceRange?.start.round() ?? 0} F',
                '${state.filters.priceRange?.end.round() ?? 50000} F',
              ),
              onChanged: (values) {
                context.read<SearchCubit>().updateFilters(
                  state.filters.copyWith(priceRange: values),
                );
              },
            ),

            SizedBox(height: 24),

            // Rating Filter
            Text('Note minimale', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            ...[5, 4, 3, 2, 1].map((rating) {
              return RadioListTile<double>(
                title: Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                    SizedBox(width: 8),
                    Text('& plus'),
                  ],
                ),
                value: rating.toDouble(),
                groupValue: state.filters.minRating ?? 0,
                onChanged: (value) {
                  context.read<SearchCubit>().updateFilters(
                    state.filters.copyWith(minRating: value),
                  );
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => ProductCardSkeleton(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Essayez d\'autres mots-clés ou modifiez les filtres',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// Add to categories list in core/data.dart
const List<String> categories = [
  'Électronique',
  'Mode',
  'Alimentation',
  'Maison',
  'Beauté',
  'Sports',
  'Livres',
  'Jouets',
];
```

---

## 2. Product Categories Landing Page

### 2.1 Create Category Models

#### File: `lib/model/category.dart`
```dart
import 'package:abdoul_express/model/product.dart';

class Category {
  final String id;
  final String name;
  final String imageUrl;
  final String imageAsset;
  final String description;
  final int productCount;
  final List<Subcategory> subcategories;
  final List<Product> featuredProducts;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.imageAsset,
    required this.description,
    required this.productCount,
    this.subcategories = const [],
    this.featuredProducts = const [],
  });
}

class Subcategory {
  final String id;
  final String name;
  final String imageUrl;
  final String imageAsset;
  final int productCount;

  Subcategory({
    required this.id,
    required this.name,
    this.imageUrl,
    this.imageAsset,
    required this.productCount,
  });
}

// Mock data - add to core/data.dart
final List<Category> mockCategories = [
  Category(
    id: '1',
    name: 'Électronique',
    imageAsset: 'assets/images/electronics.jpg',
    description: 'Découvrez nos smartphones, ordinateurs et accessoires',
    productCount: 245,
    subcategories: [
      Subcategory(id: '1-1', name: 'Smartphones', productCount: 89),
      Subcategory(id: '1-2', name: 'Ordinateurs', productCount: 67),
      Subcategory(id: '1-3', name: 'Accessoires', productCount: 89),
    ],
  ),
  Category(
    id: '2',
    name: 'Mode',
    imageAsset: 'assets/images/fashion.jpg',
    description: 'Vêtements, chaussures et accessoires pour toute la famille',
    productCount: 512,
    subcategories: [
      Subcategory(id: '2-1', name: 'Hommes', productCount: 201),
      Subcategory(id: '2-2', name: 'Femmes', productCount: 256),
      Subcategory(id: '2-3', name: 'Enfants', productCount: 55),
    ],
  ),
  // Add more categories...
];
```

#### File: `lib/features/categories/presentation/pages/category_landing_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../model/category.dart';
import '../../../core/widgets.dart';
import '../../products/presentation/pages/product_detail_page.dart';

class CategoryLandingPage extends StatelessWidget {
  final Category category;

  const CategoryLandingPage({required this.category});

  @override
  Widget build(BuildContext context) {
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
                  category.imageAsset != null
                    ? Image.asset(
                        category.imageAsset!,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha:0.7),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${category.productCount} produits disponibles',
                            style: TextStyle(
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
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchInCategoryPage(category: category),
                    ),
                  );
                },
              ),
            ],
          ),

          // Category Description
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                category.description,
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
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Sous-catégories',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: category.subcategories.length,
                      itemBuilder: (context, index) {
                        final subcategory = category.subcategories[index];
                        return Container(
                          width: 100,
                          margin: EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubcategoryProductsPage(
                                    subcategory: subcategory,
                                    categoryName: category.name,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getSubcategoryIcon(subcategory.name),
                                      size: 40,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  subcategory.name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${subcategory.productCount}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Featured Products Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Produits populaires',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Spacer(),
                  TextButton(
                    child: Text('Voir tout'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryProductsPage(category: category),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Products Grid
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = category.featuredProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(product: product),
                      ),
                    ),
                  );
                },
                childCount: category.featuredProducts.length,
              ),
            ),
          ),

          // Special Offers Banner
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha:0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offre Spéciale!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '-20% sur toute la catégorie ${category.name}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SpecialOffersPage(category: category),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text('Profiter de l\'offre'),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.local_offer,
                    color: Colors.white,
                    size: 60,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSubcategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'smartphones':
        return Icons.smartphone;
      case 'ordinateurs':
        return Icons.computer;
      case 'accessoires':
        return Icons.devices;
      case 'hommes':
        return Icons.man;
      case 'femmes':
        return Icons.woman;
      case 'enfants':
        return Icons.child_care;
      default:
        return Icons.category;
    }
  }
}
```

#### File: `lib/features/categories/presentation/pages/categories_overview_page.dart`
```dart
import 'package:flutter/material.dart';
import '../../../model/category.dart';
import '../../../core/widgets.dart';

class CategoriesOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toutes les catégories'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: mockCategories.length,
        itemBuilder: (context, index) {
          final category = mockCategories[index];
          return CategoryCard(
            category: category,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryLandingPage(category: category),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha:0.1),
                      Theme.of(context).primaryColor.withValues(alpha:0.3),
                    ],
                  ),
                ),
                child: category.imageAsset != null
                  ? Image.asset(
                      category.imageAsset!,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      _getCategoryIcon(category.name),
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${category.productCount} produits',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'électronique':
        return Icons.devices;
      case 'mode':
        return Icons.checkroom;
      case 'alimentation':
        return Icons.grocery;
      case 'maison':
        return Icons.home;
      case 'beauté':
        return Icons.face;
      case 'sports':
        return Icons.sports;
      default:
        return Icons.category;
    }
  }
}
```

---

## 3. Special Offers/Promotions Page

### 3.1 Create Promotion Models

#### File: `lib/model/promotion.dart`
```dart
import 'package:abdoul_express/model/product.dart';

class Promotion {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String imageAsset;
  final PromotionType type;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final List<Product> products;
  final String? promoCode;
  final int? minimumOrder;
  final String? category;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageAsset,
    required this.type,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    this.products = const [],
    this.promoCode,
    this.minimumOrder,
    this.category,
  });
}

enum PromotionType {
  percentage,
  fixedAmount,
  buyOneGetOne,
  freeShipping,
}

// Mock promotions - add to core/data.dart
final List<Promotion> mockPromotions = [
  Promotion(
    id: '1',
    title: 'Vente Flash -50%',
    description: 'Sur une sélection d\'articles électroniques',
    imageAsset: 'assets/images/flash_sale.jpg',
    type: PromotionType.percentage,
    discountValue: 50,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(hours: 24)),
    products: mockProducts.take(10).toList(),
  ),
  Promotion(
    id: '2',
    title: 'Livraison Gratuite',
    description: 'Pour toute commande supérieure à 10 000 F',
    imageAsset: 'assets/images/free_shipping.jpg',
    type: PromotionType.freeShipping,
    discountValue: 0,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 7)),
    minimumOrder: 10000,
  ),
  Promotion(
    id: '3',
    title: '2ème article à -30%',
    description: 'Sur tous les vêtements de la collection Mode',
    imageAsset: 'assets/images/buy_get_discount.jpg',
    type: PromotionType.percentage,
    discountValue: 30,
    category: 'Mode',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 3)),
  ),
];
```

#### File: `lib/features/promotions/presentation/pages/special_offers_page.dart`
```dart
import 'package:flutter/material.dart';
import '../../../model/promotion.dart';
import '../../../core/widgets.dart';

class SpecialOffersPage extends StatelessWidget {
  final String? categoryId;

  const SpecialOffersPage({this.categoryId});

  @override
  Widget build(BuildContext context) {
    final promotions = categoryId != null
      ? mockPromotions.where((p) => p.category == categoryId).toList()
      : mockPromotions;

    return Scaffold(
      appBar: AppBar(
        title: Text('Offres Spéciales'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => _showNotificationDialog(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Header Banner
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.orange,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meilleures Offres',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Économisez jusqu\'à -70%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CountdownTimer(),
                ],
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Toutes', true),
                    _buildFilterChip('Vente Flash', false),
                    _buildFilterChip('Livraison Gratuite', false),
                    _buildFilterChip('Meilleurs Prix', false),
                  ],
                ),
              ),
            ),
          ),

          // Promotions List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final promotion = promotions[index];
                return PromotionCard(
                  promotion: promotion,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PromotionDetailPage(promotion: promotion),
                      ),
                    );
                  },
                );
              },
              childCount: promotions.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPromoCodeDialog(context),
        icon: Icon(Icons.redeem),
        label: Text('Code Promo'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {
          // Handle filter selection
        },
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications d\'offres'),
        content: Text('Recevez les meilleures offres avant tout le monde!'),
        actions: [
          TextButton(
            child: Text('Non merci'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('M\'informer'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notifications activées!')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPromoCodeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Entrer un code promo'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Code promo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Appliquer'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Code ${controller.text} appliqué!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback onTap;

  const PromotionCard({
    required this.promotion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = DateTime.now().isAfter(promotion.endDate);
    final hoursLeft = promotion.endDate.difference(DateTime.now()).inHours;

    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4,
      child: InkWell(
        onTap: isExpired ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Visual
            if (promotion.imageAsset != null)
              Stack(
                children: [
                  Image.asset(
                    promotion.imageAsset!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  if (isExpired)
                    Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.black.withValues(alpha:0.6),
                      child: Center(
                        child: Text(
                          'EXPIRÉ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (!isExpired && hoursLeft < 24)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Il reste $hoursLeft h',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            // Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Discount Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          promotion.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDiscountColor(promotion.type),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getDiscountText(promotion),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Description
                  Text(
                    promotion.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 12),

                  // Details
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'Valable jusqu\'au ${_formatDate(promotion.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  if (promotion.minimumOrder != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'Min. ${promotion.minimumOrder} F',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (promotion.products.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      '${promotion.products.length} produits concernés',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDiscountColor(PromotionType type) {
    switch (type) {
      case PromotionType.percentage:
        return Colors.red;
      case PromotionType.fixedAmount:
        return Colors.green;
      case PromotionType.buyOneGetOne:
        return Colors.purple;
      case PromotionType.freeShipping:
        return Colors.blue;
    }
  }

  String _getDiscountText(Promotion promotion) {
    switch (promotion.type) {
      case PromotionType.percentage:
        return '-${promotion.discountValue.toInt()}%';
      case PromotionType.fixedAmount:
        return '-${promotion.discountValue.toInt()} F';
      case PromotionType.buyOneGetOne:
        return '1+1 GRATUIT';
      case PromotionType.freeShipping:
        return 'LIVRAIS OFF';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class CountdownTimer extends StatefulWidget {
  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _duration;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _duration = Duration(hours: 24, minutes: 0, seconds: 0);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration.inSeconds > 0) {
          _duration = Duration(seconds: _duration.inSeconds - 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _duration.inHours;
    final minutes = _duration.inMinutes.remainder(60);
    final seconds = _duration.inSeconds.remainder(60);

    return Column(
      children: [
        Text(
          'PROCHAINE VENTE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        Text(
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
```

---

## 4. Recently Viewed Products

### 4.1 Create Recently Viewed Service

#### File: `lib/features/recently_viewed/data/recently_viewed_service.dart`
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../model/product.dart';

class RecentlyViewedService {
  static const String _key = 'recently_viewed_products';
  static const int _maxItems = 20;

  static Future<List<Product>> getRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    return data
      .map((json) => Product.fromJson(jsonDecode(json)))
      .toList();
  }

  static Future<void> addToRecentlyViewed(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    // Remove if already exists
    data.removeWhere((item) {
      final existingProduct = Product.fromJson(jsonDecode(item));
      return existingProduct.id == product.id;
    });

    // Add to beginning
    data.insert(0, jsonEncode(product.toJson()));

    // Keep only max items
    if (data.length > _maxItems) {
      data.removeRange(_maxItems, data.length);
    }

    await prefs.setStringList(_key, data);
  }

  static Future<void> clearRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
```

#### File: `lib/features/recently_viewed/presentation/widgets/recently_viewed_carousel.dart`
```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../model/product.dart';
import '../../../core/widgets.dart';
import '../../products/presentation/pages/product_detail_page.dart';
import '../data/recently_viewed_service.dart';

class RecentlyViewedCarousel extends StatefulWidget {
  @override
  _RecentlyViewedCarouselState createState() => _RecentlyViewedCarouselState();
}

class _RecentlyViewedCarouselState extends State<RecentlyViewedCarousel> {
  List<Product> _recentProducts = [];

  @override
  void initState() {
    super.initState();
    _loadRecentlyViewed();
  }

  Future<void> _loadRecentlyViewed() async {
    final products = await RecentlyViewedService.getRecentlyViewed();
    setState(() {
      _recentProducts = products.take(10).toList(); // Show only 10
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_recentProducts.isEmpty) return SizedBox.shrink();

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Vus récemment',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Spacer(),
              TextButton(
                child: Text('Voir tout'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecentlyViewedPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Carousel
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentProducts.length,
            itemBuilder: (context, index) {
              final product = _recentProducts[index];
              return Container(
                width: 150,
                margin: EdgeInsets.only(right: 12),
                child: RecentlyViewedCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(product: product),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RecentlyViewedCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const RecentlyViewedCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => SkeletonLoader(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                  : product.imageAsset != null
                    ? Image.asset(product.imageAsset!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(0)} F',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Spacer(),
                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < product.rating
                              ? Icons.star
                              : Icons.star_border,
                            color: Colors.amber,
                            size: 12,
                          );
                        }),
                        SizedBox(width: 4),
                        Text(
                          '(${product.rating})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. New Arrivals Page

### 5.1 Create New Arrivals Page

#### File: `lib/features/new_arrivals/presentation/pages/new_arrivals_page.dart`
```dart
import 'package:flutter/material.dart';
import '../../../model/product.dart';
import '../../../core/widgets.dart';
import '../../products/presentation/pages/product_detail_page.dart';

class NewArrivalsPage extends StatelessWidget {
  // Mock new products - would come from API
  final List<Product> newArrivals = mockProducts.take(20).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveautés'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple[400]!,
                  Colors.pink[400]!,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouveaux Produits!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Découvrez les derniers arrivages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Mise à jour: Aujourd\'hui',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Filters
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('Tous', true),
                _buildCategoryChip('Électronique', false),
                _buildCategoryChip('Mode', false),
                _buildCategoryChip('Maison', false),
                _buildCategoryChip('Beauté', false),
              ],
            ),
          ),

          // Sort Options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${newArrivals.length} produits',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Spacer(),
                DropdownButton<String>(
                  value: 'Nouveautés',
                  items: [
                    DropdownMenuItem(value: 'Nouveautés', child: Text('Nouveautés')),
                    DropdownMenuItem(value: 'Prix croissant', child: Text('Prix croissant')),
                    DropdownMenuItem(value: 'Prix décroissant', child: Text('Prix décroissant')),
                    DropdownMenuItem(value: 'Populaires', child: Text('Populaires')),
                  ],
                  onChanged: (value) {
                    // Handle sort
                  },
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: newArrivals.length,
              itemBuilder: (context, index) {
                final product = newArrivals[index];
                return Stack(
                  children: [
                    ProductCard(
                      product: product,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(product: product),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.2),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'NOUVEAU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        backgroundColor: isSelected ? null : Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor.withValues(alpha:0.2),
        onSelected: (value) {
          // Handle category selection
        },
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrer les nouveautés',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Price Range
                    Text('Prix', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 12),
                RangeSlider(
                  values: RangeValues(0, 50000),
                  min: 0,
                  max: 50000,
                  divisions: 20,
                  labels: RangeLabels('0 F', '50000 F'),
                  onChanged: (values) {},
                ),
                SizedBox(height: 24),

                // Categories
                Text('Catégories', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 12),
                ...categories.map((category) => CheckboxListTile(
                  title: Text(category),
                  value: false,
                  onChanged: (value) {},
                )),
              ],
            ),
          ),

          // Apply Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: PrimaryButton(
              label: 'Appliquer les filtres',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## 6. Integration with Main App

### 6.1 Update Main Navigation

#### Add to `lib/root_shell.dart`
```dart
// In the HomePage widget, add these sections:

// After the promotions banner in HomePage
RecentlyViewedCarousel(),

// In the Categories section
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriesOverviewPage(),
      ),
    );
  },
  child: Container(
    padding: EdgeInsets.all(16),
    child: Row(
      children: [
        Text(
          'Voir toutes les catégories',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        Spacer(),
        Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor),
      ],
    ),
  ),
),

// In the floatingActionButton or AppBar
actions: [
  IconButton(
    icon: Icon(Icons.local_offer),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpecialOffersPage(),
        ),
      );
    },
  ),
],
```

### 6.2 Update Product Detail Page

#### In `product_detail_page.dart`
```dart
// In the initState method
@override
void initState() {
  super.initState();
  // Add to recently viewed
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await RecentlyViewedService.addToRecentlyViewed(widget.product);
  });
}
```

---

## 7. Dependencies to Add

### Add to `pubspec.yaml`
```yaml
dependencies:
  cached_network_image: ^3.3.1
  shared_preferences: ^2.2.2
  shimmer: ^3.0.0
```

---

## 8. Key Features Summary

### Implemented Features:
1. **Search Results Page** - Advanced search with filters and sorting
2. **Category Landing Pages** - Dedicated pages for each category
3. **Special Offers Page** - Centralized promotions display
4. **Recently Viewed Carousel** - Quick access to browsing history
5. **New Arrivals Page** - Fresh products showcase

### UI/UX Improvements:
- Clean, intuitive navigation
- Visual feedback and loading states
- Responsive design for various screen sizes
- Accessibility considerations
- Performance optimizations with image caching

### Technical Implementation:
- State management with BLoC pattern
- Local storage for recently viewed products
- Mock data ready for API integration
- Modular, reusable components
- Clean architecture principles

This implementation plan provides a comprehensive product discovery experience that will help users easily find and explore products, increasing engagement and conversion rates.