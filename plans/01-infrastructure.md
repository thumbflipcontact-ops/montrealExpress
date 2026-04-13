# Phase 1: Infrastructure & API Client

> Week 1: Build the foundation for all API communication

## Goals

- [ ] Add required dependencies
- [ ] Create API client with Dio
- [ ] Setup environment configuration
- [ ] Implement interceptors (auth, logging, error)
- [ ] Create API response wrapper
- [ ] Setup connectivity monitoring
- [ ] Create base repository pattern

## Estimated Time: 3-4 days

---

## Step 1: Add Dependencies

### 1.1 Update pubspec.yaml

```yaml
# Add to dependencies section
dependencies:
  flutter:
    sdk: flutter
  
  # Existing dependencies remain...
  
  # HTTP & Networking - NEW
  dio: ^5.4.0                    # HTTP client
  retrofit: ^4.0.3               # Type-safe API clients
  connectivity_plus: ^5.0.2      # Network state detection
  
  # Authentication - NEW
  flutter_secure_storage: ^9.0.0 # Secure token storage
  jwt_decoder: ^2.0.1            # JWT token handling
  
  # Environment - NEW
  flutter_dotenv: ^5.1.0         # Environment variables

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Existing dev dependencies remain...
  
  # Code Generation - NEW
  retrofit_generator: ^8.0.6     # Retrofit code gen
  json_serializable: ^6.7.1      # JSON serialization
  build_runner: ^2.4.4           # (update if needed)
```

### 1.2 Install Dependencies

```bash
flutter pub get
```

---

## Step 2: Create Environment Configuration

### 2.1 Create Environment Files

```bash
# In project root
touch .env
touch .env.development
touch .env.production
```

### 2.2 Add to .gitignore

```gitignore
# Environment files
.env
.env.development
.env.production
```

### 2.3 Create Template (.env.example)

```env
# API Configuration
API_BASE_URL=https://api.abdoulexpress.com/api/v1
API_KEY=your_api_key_here

# Feature Flags
ENABLE_LOGGING=true
ENABLE_OFFLINE_MODE=true
```

### 2.4 Create API Config Class

**File:** `lib/core/api/api_config.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: _getEnvFileName());
  }

  static String _getEnvFileName() {
    if (kReleaseMode) return '.env.production';
    return '.env.development';
  }

  // Base URL
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 
           'https://api.abdoulexpress.com/api/v1';
  }

  // API Key (if needed)
  static String? get apiKey => dotenv.env['API_KEY'];

  // Feature Flags
  static bool get enableLogging {
    return dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  }

  static bool get enableOfflineMode {
    return dotenv.env['ENABLE_OFFLINE_MODE']?.toLowerCase() != 'false';
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
```

---

## Step 3: Create API Exceptions

**File:** `lib/core/api/api_exceptions.dart`

```dart
abstract class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  ApiException(this.message, {this.code, this.details});

  @override
  String toString() => 'ApiException: $message (code: $code)';
}

// Network Errors
class NetworkException extends ApiException {
  NetworkException() : super(
    'Pas de connexion internet. Vérifiez votre réseau.',
    code: 'NO_CONNECTION',
  );
}

class TimeoutException extends ApiException {
  TimeoutException() : super(
    'La connexion a expiré. Réessayez.',
    code: 'TIMEOUT',
  );
}

// Authentication Errors
class UnauthorizedException extends ApiException {
  UnauthorizedException() : super(
    'Session expirée. Veuillez vous reconnecter.',
    code: 'UNAUTHORIZED',
  );
}

class ForbiddenException extends ApiException {
  ForbiddenException() : super(
    'Accès refusé.',
    code: 'FORBIDDEN',
  );
}

// Validation Errors
class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;

  ValidationException({
    required String message,
    required this.fieldErrors,
  }) : super(message, code: 'VALIDATION_ERROR');
}

// Server Errors
class ServerException extends ApiException {
  ServerException({String? message}) : super(
    message ?? 'Erreur serveur. Réessayez plus tard.',
    code: 'SERVER_ERROR',
  );
}

class NotFoundException extends ApiException {
  NotFoundException({String? resource}) : super(
    resource != null 
      ? '$resource non trouvé' 
      : 'Ressource non trouvée',
    code: 'NOT_FOUND',
  );
}

// Conflict Error
class ConflictException extends ApiException {
  ConflictException({String? message}) : super(
    message ?? 'Conflit de données.',
    code: 'CONFLICT',
  );
}
```

---

## Step 4: Create API Response Wrapper

**File:** `lib/core/api/api_response.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;
  final DateTime? timestamp;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  bool get isSuccess => success && error == null;
}

@JsonSerializable()
class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

@JsonSerializable()
class PaginationData {
  final int page;
  final int limit;
  final int total;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  @JsonKey(name: 'has_prev')
  final bool hasPrev;

  PaginationData({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) =>
      _$PaginationDataFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDataToJson(this);
}

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final PaginationData pagination;

  PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
```

**Run code generation:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Step 5: Create Secure Token Storage

**File:** `lib/core/storage/secure_storage.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accountName: 'abdoul_express_tokens',
    ),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  // Access Token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  // Refresh Token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // Token Expiry
  static Future<DateTime?> getTokenExpiry() async {
    final expiryString = await _storage.read(key: _tokenExpiryKey);
    if (expiryString != null) {
      return DateTime.tryParse(expiryString);
    }
    return null;
  }

  static Future<void> setTokenExpiry(DateTime expiry) async {
    await _storage.write(
      key: _tokenExpiryKey, 
      value: expiry.toIso8601String(),
    );
  }

  // Clear all tokens
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }
}
```

---

## Step 6: Create API Interceptors

### 6.1 Auth Interceptor

**File:** `lib/core/api/interceptors/auth_interceptor.dart`

```dart
import 'package:dio/dio.dart';
import '../secure_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for these endpoints
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/verify',
      '/auth/refresh',
      '/products',
      '/categories',
    ];

    final isPublic = publicEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!isPublic) {
      final token = await SecureStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Add language header
    options.headers['Accept-Language'] = 'fr'; // TODO: Get from LanguageCubit

    handler.next(options);
  }
}
```

### 6.2 Error Interceptor

**File:** `lib/core/api/interceptors/error_interceptor.dart`

```dart
import 'package:dio/dio.dart';
import '../api_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioError(err);
    // You can emit events to a global error handler here
    handler.reject(err..error = exception);
  }

  ApiException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return NetworkException();

      case DioExceptionType.badResponse:
        return _mapHttpError(error.response);

      default:
        return ServerException();
    }
  }

  ApiException _mapHttpError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: data?['error']?['message'] ?? 'Données invalides',
          fieldErrors: _parseFieldErrors(data),
        );
      case 401:
        return UnauthorizedException();
      case 403:
        return ForbiddenException();
      case 404:
        return NotFoundException();
      case 409:
        return ConflictException(
          message: data?['error']?['message'],
        );
      case 422:
        return ValidationException(
          message: data?['error']?['message'] ?? 'Validation échouée',
          fieldErrors: _parseFieldErrors(data),
        );
      case 500:
      case 502:
      case 503:
        return ServerException(
          message: data?['error']?['message'],
        );
      default:
        return ServerException();
    }
  }

  Map<String, List<String>> _parseFieldErrors(dynamic data) {
    final errors = <String, List<String>>{};
    final fieldErrors = data?['error']?['details']?['fields'];
    if (fieldErrors != null) {
      fieldErrors.forEach((key, value) {
        errors[key] = List<String>.from(value);
      });
    }
    return errors;
  }
}
```

### 6.3 Logging Interceptor

**File:** `lib/core/api/interceptors/logging_interceptor.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api_config.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (ApiConfig.enableLogging && kDebugMode) {
      debugPrint('🌐 REQUEST: ${options.method} ${options.uri}');
      debugPrint('Headers: ${options.headers}');
      debugPrint('Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (ApiConfig.enableLogging && kDebugMode) {
      debugPrint('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (ApiConfig.enableLogging && kDebugMode) {
      debugPrint('❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}');
      debugPrint('Message: ${err.message}');
      debugPrint('Response: ${err.response?.data}');
    }
    handler.next(err);
  }
}
```

---

## Step 7: Create Dio Client

**File:** `lib/core/api/dio_client.dart`

```dart
import 'package:dio/dio.dart';
import 'api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      if (ApiConfig.enableLogging) LoggingInterceptor(),
    ]);

    return dio;
  }

  // Reset instance (useful for testing)
  static void reset() {
    _instance = null;
  }
}
```

---

## Step 8: Create Connectivity Service

**File:** `lib/core/services/connectivity_service.dart`

```dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static final StreamController<bool> _connectionController = 
      StreamController<bool>.broadcast();

  static Stream<bool> get connectionStream => _connectionController.stream;

  static Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static void initialize() {
    _connectivity.onConnectivityChanged.listen((result) {
      final hasConnection = result != ConnectivityResult.none;
      _connectionController.add(hasConnection);
    });
  }

  static void dispose() {
    _connectionController.close();
  }
}
```

---

## Step 9: Create Base Repository

**File:** `lib/core/repositories/base_repository.dart`

```dart
import 'package:dio/dio.dart';
import '../api/api_exceptions.dart';
import '../api/api_response.dart';
import '../services/connectivity_service.dart';

abstract class BaseRepository {
  Future<T> handleRequest<T>({
    required Future<T> Function() request,
    T? fallback,
  }) async {
    try {
      // Check connectivity
      if (!await ConnectivityService.isConnected) {
        if (fallback != null) {
          return fallback;
        }
        throw NetworkException();
      }

      return await request();
    } on DioException catch (e) {
      if (e.error is ApiException) {
        rethrow;
      }
      throw ServerException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // Parse API response
  T parseResponse<T>(
    ApiResponse<T> response, {
    String? customErrorMessage,
  }) {
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    
    throw ServerException(
      message: customErrorMessage ?? response.error?.message,
    );
  }
}
```

---

## Step 10: Update Main.dart

Add initialization code to main.dart:

```dart
import 'package:flutter/material.dart';
import 'core/api/api_config.dart';
import 'core/services/connectivity_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment config
  await ApiConfig.initialize();
  
  // Initialize connectivity monitoring
  ConnectivityService.initialize();
  
  // Initialize Hive (existing)
  await _initHive();

  runApp(const MyApp());
}
```

---

## Testing

Create a simple test to verify the setup:

**File:** `test/core/api/dio_client_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:abdoul_express/core/api/dio_client.dart';

void main() {
  group('DioClient', () {
    test('should create singleton instance', () {
      final instance1 = DioClient.instance;
      final instance2 = DioClient.instance;
      
      expect(instance1, same(instance2));
    });

    test('should have correct base options', () {
      final dio = DioClient.instance;
      
      expect(dio.options.baseUrl, isNotEmpty);
      expect(dio.options.connectTimeout, isNotNull);
      expect(dio.options.receiveTimeout, isNotNull);
    });
  });
}
```

---

## Checklist

- [ ] Dependencies added to pubspec.yaml
- [ ] Environment files created (.env, .env.development, .env.production)
- [ ] ApiConfig class created
- [ ] ApiException classes created
- [ ] ApiResponse wrapper created
- [ ] SecureStorage implemented
- [ ] AuthInterceptor created
- [ ] ErrorInterceptor created
- [ ] LoggingInterceptor created
- [ ] DioClient singleton created
- [ ] ConnectivityService created
- [ ] BaseRepository created
- [ ] Code generation run (build_runner)
- [ ] main.dart updated with initialization
- [ ] Tests passing

---

## Next Phase

➡️ [Phase 2: Authentication](./02-authentication.md)
