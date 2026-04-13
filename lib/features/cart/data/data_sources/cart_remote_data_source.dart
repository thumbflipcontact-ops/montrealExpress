import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../model/cart.dart';

/// Remote data source for cart API operations
class CartRemoteDataSource {
  late final ApiClient _apiClient;
  bool _initialized = false;

  /// Initialize the data source
  Future<void> initialize() async {
    if (_initialized) return;
    _apiClient = await ApiClient.getInstance();
    _initialized = true;
  }

  /// Get current cart (guest or user)
  Future<Cart> getCart() async {
    await initialize();

    final response = await _apiClient.get(
      ApiConfig.cartEndpoint,
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return Cart.fromJson(data);
  }

  /// Add item to cart
  Future<Cart> addToCart({
    required String productId,
    required int quantity,
  }) async {
    await initialize();

    final request = AddToCartRequest(
      productId: productId,
      quantity: quantity,
    );

    final response = await _apiClient.post(
      '${ApiConfig.cartEndpoint}/items',
      data: request.toJson(),
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return Cart.fromJson(data);
  }

  /// Update cart item quantity
  Future<Cart> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    await initialize();

    final request = UpdateCartItemRequest(quantity: quantity);

    final response = await _apiClient.put(
      '${ApiConfig.cartEndpoint}/items/$itemId',
      data: request.toJson(),
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return Cart.fromJson(data);
  }

  /// Remove item from cart
  Future<Cart> removeCartItem(String itemId) async {
    await initialize();

    final response = await _apiClient.delete(
      '${ApiConfig.cartEndpoint}/items/$itemId',
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return Cart.fromJson(data);
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    await initialize();

    await _apiClient.delete(
      ApiConfig.cartEndpoint,
    );
  }

  /// Apply coupon to cart
  Future<Cart> applyCoupon(String couponCode) async {
    await initialize();

    final request = ApplyCouponRequest(couponCode: couponCode);

    final response = await _apiClient.post(
      '${ApiConfig.cartEndpoint}/apply-coupon',
      data: request.toJson(),
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return Cart.fromJson(data);
  }

  /// Remove coupon from cart
  Future<Cart> removeCoupon() async {
    await initialize();

    final response = await _apiClient.delete(
      '${ApiConfig.cartEndpoint}/coupon',
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return Cart.fromJson(data);
  }

  /// Merge guest cart with user cart on login
  Future<Cart> mergeCart() async {
    await initialize();

    final response = await _apiClient.post(
      '${ApiConfig.cartEndpoint}/merge',
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return Cart.fromJson(data);
  }

  /// Validate cart before checkout
  Future<CartValidation> validateCart() async {
    await initialize();

    final response = await _apiClient.post(
      '${ApiConfig.cartEndpoint}/validate',
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return CartValidation.fromJson(data);
  }
}
