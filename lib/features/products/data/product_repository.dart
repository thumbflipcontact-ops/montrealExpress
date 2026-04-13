import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../core/network/api_config.dart';
import '../../../model/product.dart';
import '../../../model/category.dart';
import 'data_sources/product_remote_data_source.dart';
import 'data_sources/category_remote_data_source.dart';

/// Repository for product and category operations
/// Implements caching strategy for offline support
class ProductRepository {
  late final ProductRemoteDataSource _productDataSource;
  late final CategoryRemoteDataSource _categoryDataSource;
  late final Box<String> _cacheBox;
  bool _initialized = false;

  // Cache keys
  static const String _productsListKey = 'products_list';
  static const String _featuredProductsKey = 'featured_products';
  static const String _trendingProductsKey = 'trending_products';
  static const String _categoriesKey = 'categories';
  static const String _categoriesTreeKey = 'categories_tree';

  /// Initialize the repository
  Future<void> initialize() async {
    if (_initialized) return;

    _productDataSource = ProductRemoteDataSource();
    await _productDataSource.initialize();

    _categoryDataSource = CategoryRemoteDataSource();
    await _categoryDataSource.initialize();

    // Initialize Hive cache
    _cacheBox = await Hive.openBox<String>('product_cache');

    _initialized = true;
  }

  // ============ Product Methods ============

  /// Get products with optional filters
  /// Uses cache-first strategy with TTL
  Future<List<Product>> fetchProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    bool forceRefresh = false,
  }) async {
    await initialize();

    final cacheKey = '${_productsListKey}_${page}_${limit}_$categoryId';

    // Try cache first (if not forcing refresh)
    if (!forceRefresh) {
      final cached = await _getCachedProducts(
        cacheKey,
        ApiConfig.productListCacheDuration,
      );
      if (cached != null) return cached;
    }

    // Fetch from API
    try {
      final products = await _productDataSource.getProducts(
        page: page,
        limit: limit,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        inStock: inStock,
      );

      // Cache the results
      await _cacheProducts(cacheKey, products);

      return products;
    } catch (e) {
      // On error, return cached data if available (ignore TTL)
      final cached = await _getCachedProducts(cacheKey, null);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    await initialize();

    // Try cache first
    if (!forceRefresh) {
      final cached = await _getCachedProducts(
        _featuredProductsKey,
        ApiConfig.productListCacheDuration,
      );
      if (cached != null) return cached;
    }

    // Fetch from API
    try {
      final products = await _productDataSource.getFeaturedProducts(
        limit: limit,
      );

      await _cacheProducts(_featuredProductsKey, products);
      return products;
    } catch (e) {
      final cached = await _getCachedProducts(_featuredProductsKey, null);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Get trending products
  Future<List<Product>> getTrendingProducts({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    await initialize();

    if (!forceRefresh) {
      final cached = await _getCachedProducts(
        _trendingProductsKey,
        ApiConfig.productListCacheDuration,
      );
      if (cached != null) return cached;
    }

    try {
      final products = await _productDataSource.getTrendingProducts(
        limit: limit,
      );

      await _cacheProducts(_trendingProductsKey, products);
      return products;
    } catch (e) {
      final cached = await _getCachedProducts(_trendingProductsKey, null);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Search products
  Future<List<Product>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    await initialize();

    // Search is always fresh (no caching for search results)
    return await _productDataSource.searchProducts(
      query: query,
      page: page,
      limit: limit,
    );
  }

  /// Get product by ID
  Future<Product> getProductById(String productId) async {
    await initialize();

    final cacheKey = 'product_$productId';

    // Try cache first
    final cached = await _getCachedProducts(
      cacheKey,
      ApiConfig.productDetailsCacheDuration,
    );
    if (cached != null && cached.isNotEmpty) return cached.first;

    // Fetch from API
    try {
      final product = await _productDataSource.getProductById(productId);
      await _cacheProducts(cacheKey, [product]);
      return product;
    } catch (e) {
      final cached = await _getCachedProducts(cacheKey, null);
      if (cached != null && cached.isNotEmpty) return cached.first;
      rethrow;
    }
  }

  /// Get related products
  Future<List<Product>> getRelatedProducts({
    required String productId,
    int limit = 5,
  }) async {
    await initialize();

    // Related products are always fresh
    return await _productDataSource.getRelatedProducts(
      productId: productId,
      limit: limit,
    );
  }

  // ============ Category Methods ============

  /// Get all categories
  Future<List<Category>> getCategories({
    bool forceRefresh = false,
  }) async {
    await initialize();

    if (!forceRefresh) {
      final cached = await _getCachedCategories(
        _categoriesKey,
        ApiConfig.categoriesCacheDuration,
      );
      if (cached != null) return cached;
    }

    try {
      final categories = await _categoryDataSource.getCategories();
      await _cacheCategories(_categoriesKey, categories);
      return categories;
    } catch (e) {
      final cached = await _getCachedCategories(_categoriesKey, null);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Get categories tree
  Future<List<Category>> getCategoriesTree({
    bool forceRefresh = false,
  }) async {
    await initialize();

    if (!forceRefresh) {
      final cached = await _getCachedCategories(
        _categoriesTreeKey,
        ApiConfig.categoriesCacheDuration,
      );
      if (cached != null) return cached;
    }

    try {
      final categories = await _categoryDataSource.getCategoriesTree();
      await _cacheCategories(_categoriesTreeKey, categories);
      return categories;
    } catch (e) {
      final cached = await _getCachedCategories(_categoriesTreeKey, null);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Get category by ID
  Future<Category> getCategoryById(String categoryId) async {
    await initialize();

    final cacheKey = 'category_$categoryId';

    final cached = await _getCachedCategories(
      cacheKey,
      ApiConfig.categoriesCacheDuration,
    );
    if (cached != null && cached.isNotEmpty) return cached.first;

    try {
      final category = await _categoryDataSource.getCategoryById(categoryId);
      await _cacheCategories(cacheKey, [category]);
      return category;
    } catch (e) {
      final cached = await _getCachedCategories(cacheKey, null);
      if (cached != null && cached.isNotEmpty) return cached.first;
      rethrow;
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    await initialize();

    final cacheKey = 'category_products_${categoryId}_${page}_$limit';

    final cached = await _getCachedProducts(
      cacheKey,
      ApiConfig.productListCacheDuration,
    );
    if (cached != null) return cached;

    try {
      final products = await _categoryDataSource.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
      );
      await _cacheProducts(cacheKey, products);
      return products;
    } catch (e) {
      final cached = await _getCachedProducts(cacheKey, null);
      if (cached != null) return cached;
      rethrow;
    }
  }

  // ============ Cache Helper Methods ============

  /// Get cached products
  Future<List<Product>?> _getCachedProducts(
    String key,
    int? maxAgeSeconds,
  ) async {
    try {
      final cacheEntry = _cacheBox.get(key);
      if (cacheEntry == null) return null;

      final parts = cacheEntry.split('|||');
      if (parts.length != 2) return null;

      final timestamp = int.tryParse(parts[0]);
      if (timestamp == null) return null;

      // Check if cache is expired (if maxAge is provided)
      if (maxAgeSeconds != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > maxAgeSeconds * 1000) return null;
      }

      final jsonString = parts[1];
      final List<dynamic> jsonList = _parseJson(jsonString);

      return jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Cache products
  Future<void> _cacheProducts(String key, List<Product> products) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final jsonList = products.map((p) => p.toJson()).toList();
      final jsonString = _encodeJson(jsonList);
      await _cacheBox.put(key, '$timestamp|||$jsonString');
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Get cached categories
  Future<List<Category>?> _getCachedCategories(
    String key,
    int? maxAgeSeconds,
  ) async {
    try {
      final cacheEntry = _cacheBox.get(key);
      if (cacheEntry == null) return null;

      final parts = cacheEntry.split('|||');
      if (parts.length != 2) return null;

      final timestamp = int.tryParse(parts[0]);
      if (timestamp == null) return null;

      if (maxAgeSeconds != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > maxAgeSeconds * 1000) return null;
      }

      final jsonString = parts[1];
      final List<dynamic> jsonList = _parseJson(jsonString);

      return jsonList
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Cache categories
  Future<void> _cacheCategories(String key, List<Category> categories) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final jsonList = categories.map((c) => c.toJson()).toList();
      final jsonString = _encodeJson(jsonList);
      await _cacheBox.put(key, '$timestamp|||$jsonString');
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Parse JSON string
  List<dynamic> _parseJson(String jsonString) {
    try {
      return json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  /// Encode JSON
  String _encodeJson(List<dynamic> data) {
    try {
      return json.encode(data);
    } catch (e) {
      return '[]';
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await initialize();
    await _cacheBox.clear();
  }

  /// Clear specific cache entries
  Future<void> clearCacheFor(String key) async {
    await initialize();
    await _cacheBox.delete(key);
  }
}

// Keep old abstract class and mock for backward compatibility
abstract class ProductRepositoryInterface {
  Future<List<Product>> fetchProducts();
}

class MockProductRepository implements ProductRepositoryInterface {
  const MockProductRepository(this._data);
  final List<Product> _data;

  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _data;
  }
}
