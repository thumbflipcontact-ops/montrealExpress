import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/search_cubit.dart';
import '../../../products/presentation/pages/product_detail_page.dart';
import 'package:abdoul_express/core/design_system/components/animated_search_field.dart';
import 'package:abdoul_express/core/design_system/components/glassmorphic_nav_bubble.dart';
import 'package:abdoul_express/core/design_system/components/staggered_product_grid.dart';
import 'package:abdoul_express/core/design_system/components/empty_state_widget.dart';

import 'package:abdoul_express/core/design_system/components/organic_skeleton.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/typography.dart';
import 'package:abdoul_express/core/theme/shadows.dart';

/// Static category filter labels for the search filter panel
const _kFilterCategories = [
  'Cosmétiques',
  'Accessoires',
  'Sacs enfants',
  'Électronique',
  'Mode',
  'Alimentation',
  'Maison',
  'Beauté',
];

class SearchResultsPage extends StatefulWidget {
  final String? initialQuery;

  const SearchResultsPage({super.key, this.initialQuery});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SearchCubit>().searchProducts(widget.initialQuery!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Organic search header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryLight.withValues(alpha: 0.1),
                  AppColors.secondaryContainer.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                // Search field with filter and sort buttons
                Row(
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.small,
                        ),
                        child: Icon(Icons.arrow_back, size: 20, color: colorScheme.onSurface),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Search field
                    Expanded(
                      child: AnimatedSearchField(
                        controller: _searchController,
                        hintText: 'Rechercher des produits...',
                        onChanged: (value) {
                          setState(() {});
                          if (value.isNotEmpty) {
                            context.read<SearchCubit>().searchProducts(value);
                          }
                        },
                        onSubmitted: (value) {
                          context.read<SearchCubit>().searchProducts(value);
                        },
                        autofocus: widget.initialQuery == null,

                        // gradient: [
                        //   AppColors.primaryMain,
                        //   AppColors.primaryDark,
                        // ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Filter and sort buttons
                Row(
                  children: [
                    // Filter button
                    Expanded(
                      child: GlassmorphicNavBubble(
                        label: _showFilters ? 'Masquer' : 'Filtres',
                        icon: _showFilters
                            ? Icons.filter_list_off
                            : Icons.filter_list,
                        onTap: () =>
                            setState(() => _showFilters = !_showFilters),
                        isSelected: _showFilters,
                        size: NavBubbleSize.small,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sort button with popup menu
                    Expanded(
                      child: PopupMenuButton<SortOrder>(
                        onSelected: (order) {
                          context.read<SearchCubit>().setSortOrder(order);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: SortOrder.relevance,
                            child: Text('Pertinence'),
                          ),
                          const PopupMenuItem(
                            value: SortOrder.priceLowToHigh,
                            child: Text('Prix croissant'),
                          ),
                          const PopupMenuItem(
                            value: SortOrder.priceHighToLow,
                            child: Text('Prix décroissant'),
                          ),
                          const PopupMenuItem(
                            value: SortOrder.rating,
                            child: Text('Note'),
                          ),
                          const PopupMenuItem(
                            value: SortOrder.newest,
                            child: Text('Nouveautés'),
                          ),
                        ],
                        child: GlassmorphicNavBubble(
                          label: 'Trier',
                          icon: Icons.sort,
                          onTap: () {},
                          size: NavBubbleSize.small,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Row(
              children: [
                // Filters sidebar
                if (_showFilters)
                  SizedBox(width: 280, child: _buildFiltersPanel()),
                // Results
                Expanded(
                  child: BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return _buildLoadingState();
                      }

                      if (state.products.isEmpty && state.query.isNotEmpty) {
                        return EmptyStates.noSearchResults(query: state.query);
                      }

                      if (state.products.isEmpty && state.query.isEmpty) {
                        return _buildInitialState();
                      }

                      return Column(
                        children: [
                          // Results header with count
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  '${state.products.length} résultats',
                                  style:
                                      AppTypography.buildTextTheme(
                                        Theme.of(context).brightness,
                                      ).titleMedium!.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                ),
                                const Spacer(),
                                if (state.filters.categories.isNotEmpty ||
                                    state.filters.priceRange != null ||
                                    state.filters.minRating != null)
                                  TextButton(
                                    onPressed: () {
                                      context.read<SearchCubit>().updateFilters(
                                        const SearchFilters(),
                                      );
                                    },
                                    child: Text(
                                      'Effacer',
                                      style: TextStyle(
                                        color: AppColors.primaryMain,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Active filter chips
                          if (state.filters.categories.isNotEmpty)
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: state.filters.categories.length,
                                itemBuilder: (context, index) {
                                  final category =
                                      state.filters.categories[index];
                                  final gradient =
                                      AppColors.getCategoryGradient(category);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: gradient,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow:
                                            AppShadows.createColoredShadow(
                                              color: gradient.first,
                                              opacity: 0.25,
                                            ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            category,
                                            style:
                                                AppTypography.categoryChipStyle()
                                                    .copyWith(
                                                      color: Colors.white,
                                                    ),
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () {
                                              final newCategories =
                                                  List<String>.from(
                                                    state.filters.categories,
                                                  )..remove(category);
                                              context
                                                  .read<SearchCubit>()
                                                  .updateFilters(
                                                    state.filters.copyWith(
                                                      categories: newCategories,
                                                    ),
                                                  );
                                            },
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          // Product grid with staggered layout
                          Expanded(
                            child: StaggeredProductGrid(
                              products: state.products,
                              onProductTap: (product) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsPage(product: product),
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
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Categories Filter
            Text('Catégories', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final category in _kFilterCategories)
              CheckboxListTile(
                title: Text(category),
                value: state.filters.categories.contains(category),
                onChanged: (value) {
                  final newCategories = List<String>.from(
                    state.filters.categories,
                  );
                  if (value!) {
                    newCategories.add(category);
                  } else {
                    newCategories.remove(category);
                  }
                  context.read<SearchCubit>().updateFilters(
                    state.filters.copyWith(categories: newCategories),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Price Range Filter
            Text('Prix', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            RangeSlider(
              values: state.filters.priceRange ?? const RangeValues(0, 50000),
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

            const SizedBox(height: 24),

            // Rating Filter
            Text(
              'Note minimale',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final rating in [5, 4, 3, 2, 1])
              RadioListTile<double>(
                title: Row(
                  children: [
                    for (var i = 0; i < 5; i++)
                      Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    const Text('& plus'),
                  ],
                ),
                value: rating.toDouble(),
                groupValue: state.filters.minRating ?? 0,
                onChanged: (value) {
                  context.read<SearchCubit>().updateFilters(
                    state.filters.copyWith(minRating: value),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Clear Filters Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<SearchCubit>().updateFilters(
                    const SearchFilters(),
                  );
                },
                child: const Text('Effacer tous les filtres'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const ProductGridSkeleton(itemCount: 6);
  }

  Widget _buildInitialState() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search illustration
          Center(
            child:
                Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryLight.withValues(alpha: 0.3),
                            AppColors.primaryMain.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search,
                        size: 56,
                        color: AppColors.primaryMain,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 400))
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),
          ),
          const SizedBox(height: 24),
          Center(
            child:
                Text(
                      'Que cherchez-vous?',
                      style: AppTypography.buildTextTheme(Theme.of(context).brightness).headlineSmall!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 200))
                    .slideY(begin: 0.2, end: 0),
          ),
          const SizedBox(height: 8),
          Center(
            child:
                Text(
                      'Utilisez la barre de recherche pour trouver des produits',
                      style: AppTypography.inputStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 300))
                    .slideY(begin: 0.2, end: 0),
          ),
          const SizedBox(height: 32),
          // Popular searches
          PopularSearches(
            searches: const [
              'Smartphones',
              'Ordinateurs',
              'Mode',
              'Maison',
              'Beauté',
              'Électronique',
            ],
            onSearchSelected: (search) {
              _searchController.text = search;
              context.read<SearchCubit>().searchProducts(search);
            },
          ),
          const SizedBox(height: 24),
          // Recent searches (mock data - would come from local storage)
          RecentSearches(
            searches: const [
              'iPhone 15',
              'Casque Bluetooth',
              'Chaussures Nike',
            ],
            onSearchSelected: (search) {
              _searchController.text = search;
              context.read<SearchCubit>().searchProducts(search);
            },
            onSearchDeleted: (search) {
              // Remove from recent searches
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(suggestion),
      onPressed: () {
        _searchController.text = suggestion;
        context.read<SearchCubit>().searchProducts(suggestion);
      },
    );
  }
}
