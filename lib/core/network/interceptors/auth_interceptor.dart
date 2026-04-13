import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

/// Interceptor that adds authentication tokens to requests
/// and handles token refresh when access token expires
class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final SharedPreferences prefs;

  // Keys for storing tokens
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _sessionIdKey = 'session_id';
  static const String _isGuestKey = 'is_guest';

  AuthInterceptor({
    required this.dio,
    required this.prefs,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add authentication header if token exists
    final token = _getAccessToken();
    if (token != null) {
      options.headers[ApiConfig.authorizationHeader] = 'Bearer $token';
    }

    // Add session ID for guest users
    final sessionId = _getSessionId();
    if (sessionId != null && _isGuest()) {
      options.headers[ApiConfig.sessionIdHeader] = sessionId;
    }

    // Ensure content type and accept headers
    options.headers[ApiConfig.contentTypeHeader] = ApiConfig.contentTypeJson;
    options.headers[ApiConfig.acceptHeader] = ApiConfig.acceptJson;

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If we get a 401 and have a refresh token, try to refresh
    if (err.response?.statusCode == 401) {
      final refreshToken = _getRefreshToken();

      // Don't try to refresh on login/register/guest endpoints
      final isAuthEndpoint = err.requestOptions.path.contains('/auth/login') ||
          err.requestOptions.path.contains('/auth/register') ||
          err.requestOptions.path.contains('/auth/guest') ||
          err.requestOptions.path.contains('/auth/refresh');

      if (refreshToken != null && !isAuthEndpoint && !_isGuest()) {
        try {
          // Try to refresh the token
          final newTokens = await _refreshAccessToken(refreshToken);

          if (newTokens != null) {
            // Save new tokens
            final accessToken = newTokens['accessToken'];
            final refreshToken = newTokens['refreshToken'];

            if (accessToken != null) {
              await _saveAccessToken(accessToken);
            }
            if (refreshToken != null) {
              await _saveRefreshToken(refreshToken);
            }

            // Retry the original request with new token
            final opts = err.requestOptions;
            opts.headers[ApiConfig.authorizationHeader] =
                'Bearer ${newTokens['accessToken']}';

            final response = await dio.fetch(opts);
            return handler.resolve(response);
          }
        } catch (e) {
          // Refresh failed, clear tokens and proceed with error
          await clearAuth();
        }
      }

      // If we couldn't refresh or don't have refresh token, clear auth
      if (!isAuthEndpoint) {
        await clearAuth();
      }
    }

    handler.next(err);
  }

  /// Refresh the access token using refresh token
  Future<Map<String, String>?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await dio.post(
        ApiConfig.refreshEndpoint,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            ApiConfig.authorizationHeader: 'Bearer $refreshToken',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final responseData = data['data'];
          if (responseData != null) {
            return {
              'accessToken': responseData['accessToken'] ?? '',
              'refreshToken': responseData['refreshToken'] ?? '',
            };
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Token storage methods
  String? _getAccessToken() => prefs.getString(_accessTokenKey);
  String? _getRefreshToken() => prefs.getString(_refreshTokenKey);
  String? _getSessionId() => prefs.getString(_sessionIdKey);
  bool _isGuest() => prefs.getBool(_isGuestKey) ?? false;

  Future<void> _saveAccessToken(String token) async {
    await prefs.setString(_accessTokenKey, token);
  }

  Future<void> _saveRefreshToken(String token) async {
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Save session ID for guest users
  static Future<void> saveSessionId(
    SharedPreferences prefs,
    String sessionId,
  ) async {
    await prefs.setString(_sessionIdKey, sessionId);
    await prefs.setBool(_isGuestKey, true);
  }

  /// Save authentication tokens for logged-in users
  static Future<void> saveTokens(
    SharedPreferences prefs, {
    required String accessToken,
    String? refreshToken,
  }) async {
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    await prefs.setBool(_isGuestKey, false);
  }

  /// Clear all authentication data
  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_isGuestKey);
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final isGuest = prefs.getBool(_isGuestKey) ?? false;
    return token != null && !isGuest;
  }

  /// Check if user is guest
  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey) ?? false;
  }

  /// Get current access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get current session ID
  static Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionIdKey);
  }
}
