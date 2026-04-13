import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../model/order_api.dart';

/// Remote data source for orders API operations
class OrdersRemoteDataSource {
  late final ApiClient _apiClient;
  bool _initialized = false;

  /// Initialize the data source
  Future<void> initialize() async {
    if (_initialized) return;
    _apiClient = await ApiClient.getInstance();
    _initialized = true;
  }

  /// Create order from cart
  /// Requires shippingAddress (AddressDto) and paymentMethod
  Future<OrderApi> createOrder({
    required AddressDto shippingAddress,
    required PaymentMethodType paymentMethod,
    AddressDto? billingAddress,
    String? notes,
    String? phoneNumber,
  }) async {
    await initialize();

    final request = CreateOrderRequest(
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      paymentMethod: paymentMethod,
      notes: notes,
      phoneNumber: phoneNumber,
    );

    final response = await _apiClient.post(
      ApiConfig.ordersEndpoint,
      data: request.toJson(),
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return OrderApi.fromJson(data);
  }

  /// Get user orders with pagination
  Future<OrderListResponse> getUserOrders({
    int page = 1,
    int limit = 20,
    OrderStatusApi? status,
  }) async {
    await initialize();

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null) 'status': status.name,
    };

    final response = await _apiClient.get(
      '${ApiConfig.ordersEndpoint}/me',
      queryParameters: queryParams,
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return OrderListResponse.fromJson(data);
  }

  /// Get order details by ID
  Future<OrderApi> getOrderById(String orderId) async {
    await initialize();

    final response = await _apiClient.get(
      '${ApiConfig.ordersEndpoint}/me/$orderId',
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Order not found');
    }

    return OrderApi.fromJson(data);
  }

  /// Cancel order
  Future<OrderApi> cancelOrder(String orderId) async {
    await initialize();

    final response = await _apiClient.put(
      '${ApiConfig.ordersEndpoint}/me/$orderId/cancel',
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return OrderApi.fromJson(data);
  }
}
