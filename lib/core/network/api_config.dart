/// API configuration constants for Abdoul Express backend
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Base URL for the production API
  static const String baseUrl = 'https://aexpress-api.alfajarsoft.com/api/v1';

  /// Connection timeout in milliseconds
  static const int connectTimeout = 30000; // 30 seconds

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000; // 30 seconds

  /// Send timeout in milliseconds
  static const int sendTimeout = 30000; // 30 seconds

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String cartEndpoint = '/cart';
  static const String ordersEndpoint = '/orders';
  static const String addressesEndpoint = '/addresses';
  static const String wishlistEndpoint = '/wishlist';
  static const String reviewsEndpoint = '/reviews';
  static const String paymentsEndpoint = '/payments';
  static const String uploadsEndpoint = '/uploads';

  // Auth endpoints
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String phoneInitiateEndpoint = '$authEndpoint/phone/initiate';
  static const String phoneVerifyEndpoint = '$authEndpoint/phone/verify';
  static const String guestEndpoint = '$authEndpoint/guest';
  static const String refreshEndpoint = '$authEndpoint/refresh';
  static const String logoutEndpoint = '$authEndpoint/logout';
  static const String profileEndpoint = '$authEndpoint/profile';
  static const String changePasswordEndpoint = '$authEndpoint/change-password';
  static const String forgotPasswordEndpoint = '$authEndpoint/forgot-password';
  static const String verifyResetOtpEndpoint = '$authEndpoint/verify-reset-otp';

  // Cache durations (in seconds)
  static const int productListCacheDuration = 3600; // 1 hour
  static const int productDetailsCacheDuration = 1800; // 30 minutes
  static const int categoriesCacheDuration = 21600; // 6 hours

  // Retry configuration
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 second

  // Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String authorizationHeader = 'Authorization';
  static const String acceptHeader = 'Accept';
  static const String sessionIdHeader = 'X-Session-ID';

  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
}
