import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../model/category.dart';
import '../../../../model/product.dart';

/// Remote data source for category API operations
class CategoryRemoteDataSource {
  late final ApiClient _apiClient;
  bool _initialized = false;

  /// Initialize the data source
  Future<void> initialize() async {
    if (_initialized) return;
    _apiClient = await ApiClient.getInstance();
    _initialized = true;
  }

  /// Get all categories (flat list)
  Future<List<Category>> getCategories() async {
    await initialize();

    final response = await _apiClient.get(
      ApiConfig.categoriesEndpoint,
    );

    final data = _apiClient.parseResponse<List<dynamic>>(response);
    if (data == null) {
      return [];
    }

    return data
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get categories as a tree structure
  Future<List<Category>> getCategoriesTree() async {
    await initialize();

    final response = await _apiClient.get(
      '${ApiConfig.categoriesEndpoint}/tree',
    );

    final data = _apiClient.parseResponse<List<dynamic>>(response);
    if (data == null) {
      return [];
    }

    return data
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get category details by ID
  Future<Category> getCategoryById(String categoryId) async {
    await initialize();

    final response = await _apiClient.get(
      '${ApiConfig.categoriesEndpoint}/$categoryId',
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Category not found');
    }

    return Category.fromJson(data);
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    await initialize();

    final response = await _apiClient.get(
      '${ApiConfig.categoriesEndpoint}/$categoryId/products',
      queryParameters: {
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
}
