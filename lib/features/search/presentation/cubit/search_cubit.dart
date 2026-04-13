import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model/product.dart';
import '../../../../features/products/data/product_repository.dart';

class SearchCubit extends Cubit<SearchState> {
  final ProductRepository _productRepository;

  SearchCubit({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(SearchState.initial());

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(isLoading: false, products: [], allProducts: [], query: ''));
      return;
    }

    emit(state.copyWith(isLoading: true, query: query));

    try {
      final results = await _productRepository.searchProducts(query: query);
      emit(state.copyWith(
        isLoading: false,
        products: results,
        allProducts: results,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, products: [], allProducts: []));
    }
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
    var filtered = List<Product>.from(state.allProducts);

    if (state.filters.categories.isNotEmpty) {
      filtered = filtered
          .where((p) => state.filters.categories.contains(p.category))
          .toList();
    }

    if (state.filters.priceRange != null) {
      final range = state.filters.priceRange!;
      filtered = filtered
          .where((p) => p.price >= range.start && p.price <= range.end)
          .toList();
    }

    if (state.filters.minRating != null) {
      filtered = filtered
          .where((p) => p.rating >= state.filters.minRating!)
          .toList();
    }

    emit(state.copyWith(products: filtered, allProducts: state.allProducts));
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
        sorted = List.from(sorted.reversed);
        break;
      case SortOrder.relevance:
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
      allProducts: [],
      query: '',
      filters: const SearchFilters(),
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

  const SearchFilters({
    this.categories = const [],
    this.priceRange,
    this.minRating,
  });

  SearchFilters copyWith({
    List<String>? categories,
    RangeValues? priceRange,
    double? minRating,
  }) {
    return SearchFilters(
      categories: categories ?? this.categories,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
    );
  }
}

enum SortOrder { relevance, priceLowToHigh, priceHighToLow, rating, newest }
