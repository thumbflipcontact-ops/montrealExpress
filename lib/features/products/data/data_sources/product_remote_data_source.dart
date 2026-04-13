import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../model/product.dart';

/// Remote data source for product API operations
class ProductRemoteDataSource {
  late final ApiClient _apiClient;
  bool _initialized = false;

  /// Initialize the data source
  Future<void> initialize() async {
    if (_initialized) return;
    _apiClient = await ApiClient.getInstance();
    _initialized = true;
  }

  /// Get list of products with optional filters
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20)
  /// [categoryId] - Filter by category
  /// [minPrice] - Minimum price filter
  /// [maxPrice] - Maximum price filter
  /// [inStock] - Filter by stock availability
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
  }) async {
    await initialize();

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (categoryId != null) 'categoryId': categoryId,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (inStock != null) 'inStock': inStock,
    };

    final response = await _apiClient.get(
      ApiConfig.productsEndpoint,
      queryParameters: queryParams,
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    // Backend returns { items: [...], total, page, pageSize, totalPages }
    final items = data['items'] as List<dynamic>?;
    if (items == null) {
      return [];
    }

    return items
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    await initialize();

    final response = await _apiClient.get(
      '${ApiConfig.productsEndpoint}/featured',
      queryParameters: {'limit': limit},
    );

    final data = _apiClient.parseResponse<List<dynamic>>(response);
    if (data == null) {
      return [];
    }

    return data
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get trending products
  Future<List<Product>> getTrendingProducts({int limit = 10}) async {
    await initialize();

    final response = await _apiClient.get(
      '${ApiConfig.productsEndpoint}/trending',
      queryParameters: {'limit': limit},
    );

    final data = _apiClient.parseResponse<List<dynamic>>(response);
    if (data == null) {
      return [];
    }

    return data
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Search products by query
  Future<List<Product>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    await initialize();

    final response = await _apiClient.get(
      '${ApiConfig.productsEndpoint}/search',
      queryParameters: {
        'q': query,
        'page': page,
        'limit': limit,
      },
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    final items = data['items'] as List<dynamic>?;
    if (items == null) {
      return [];
    }

    return items
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get product details by ID
  Future<Product> getProductById(String productId) async {
    await initialize();

    final response = await _apiClient.get(
      '${ApiConfig.productsEndpoint}/$productId',
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Product not found');
    }

    return Product.fromJson(data);
  }

  /// Get related products for a given product
  Future<List<Product>> getRelatedProducts({
    required String productId,
    int limit = 5,
  }) async {
    await initialize();

    final response = await _apiClient.get(
      '${ApiConfig.productsEndpoint}/$productId/related',
      queryParameters: {'limit': limit},
    );

    final data = _apiClient.parseResponse<List<dynamic>>(response);
    if (data == null) {
      return [];
    }

    return data
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
