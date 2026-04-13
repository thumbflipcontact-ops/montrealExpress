# Phase 2: Authentication System

> Week 2: Implement real authentication with JWT tokens

## Goals

- [ ] Create auth DTOs (request/response models)
- [ ] Implement auth remote data source
- [ ] Implement auth local data source
- [ ] Create auth repository implementation
- [ ] Add token refresh mechanism
- [ ] Update AuthCubit for API integration
- [ ] Handle OTP verification flow

## Estimated Time: 4-5 days

---

## Backend API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register with email/phone |
| POST | `/auth/verify` | Verify email/phone OTP |
| POST | `/auth/login` | Login with credentials |
| POST | `/auth/login-phone` | Request phone OTP |
| POST | `/auth/verify-otp` | Verify phone OTP |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | Logout user |
| GET | `/auth/me` | Get current user |

---

## Step 1: Create Auth DTOs

### 1.1 Login Request

**File:** `lib/features/auth/data/models/login_request.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  final String? email;
  final String? phone;
  final String password;

  LoginRequest({
    this.email,
    this.phone,
    required this.password,
  }) : assert(email != null || phone != null, 'Email or phone required');

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
```

### 1.2 Register Request

**File:** `lib/features/auth/data/models/register_request.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String? email;
  final String? phone;
  final String password;
  final String firstName;
  final String lastName;

  RegisterRequest({
    this.email,
    this.phone,
    required this.password,
    required this.firstName,
    required this.lastName,
  }) : assert(email != null || phone != null, 'Email or phone required');

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
```

### 1.3 Token Response

**File:** `lib/features/auth/data/models/token_response.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'token_response.g.dart';

@JsonSerializable()
class TokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  
  @JsonKey(name: 'token_type')
  final String tokenType;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'Bearer',
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);

  DateTime get expiryDate => 
      DateTime.now().add(Duration(seconds: expiresIn));
}
```

### 1.4 User Model

**File:** `lib/features/auth/data/models/user_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String role;
  @JsonKey(name: 'email_verified')
  final bool emailVerified;
  @JsonKey(name: 'phone_verified')
  final bool phoneVerified;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.role = 'customer',
    this.emailVerified = false,
    this.phoneVerified = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get fullName => '$firstName $lastName';

  bool get isVerified => emailVerified || phoneVerified;
}
```

### 1.5 OTP Request/Response

**File:** `lib/features/auth/data/models/otp_request.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'otp_request.g.dart';

@JsonSerializable()
class OtpRequest {
  final String phone;

  OtpRequest({required this.phone});

  factory OtpRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OtpRequestToJson(this);
}

@JsonSerializable()
class OtpVerifyRequest {
  final String phone;
  final String otp;

  OtpVerifyRequest({
    required this.phone,
    required this.otp,
  });

  factory OtpVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyRequestToJson(this);
}

@JsonSerializable()
class OtpResponse {
  @JsonKey(name: 'message_id')
  final String? messageId;
  final String? status;
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  OtpResponse({
    this.messageId,
    this.status,
    this.expiresIn = 300,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OtpResponseToJson(this);
}
```

---

## Step 2: Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Step 3: Create Auth Remote Data Source

**File:** `lib/features/auth/data/datasources/auth_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/api/api_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/token_response.dart';
import '../models/user_model.dart';
import '../models/otp_request.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @POST('/auth/login')
  Future<ApiResponse<TokenResponse>> login(
    @Body() LoginRequest request,
  );

  @POST('/auth/register')
  Future<ApiResponse<TokenResponse>> register(
    @Body() RegisterRequest request,
  );

  @POST('/auth/verify')
  Future<ApiResponse<TokenResponse>> verify(
    @Body() Map<String, String> request,
  );

  @POST('/auth/login-phone')
  Future<ApiResponse<OtpResponse>> requestPhoneOtp(
    @Body() OtpRequest request,
  );

  @POST('/auth/verify-otp')
  Future<ApiResponse<TokenResponse>> verifyOtp(
    @Body() OtpVerifyRequest request,
  );

  @POST('/auth/refresh')
  Future<ApiResponse<TokenResponse>> refreshToken(
    @Body() Map<String, String> request,
  );

  @POST('/auth/logout')
  Future<ApiResponse<void>> logout();

  @GET('/auth/me')
  Future<ApiResponse<UserModel>> getCurrentUser();
}
```

---

## Step 4: Create Auth Local Data Source

**File:** `lib/features/auth/data/datasources/auth_local_datasource.dart`

```dart
import '../../../../core/storage/secure_storage.dart';
import '../models/token_response.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  static const String _userKey = 'user_data';

  // Token operations
  Future<void> saveTokens(TokenResponse tokens) async {
    await SecureStorage.setAccessToken(tokens.accessToken);
    await SecureStorage.setRefreshToken(tokens.refreshToken);
    await SecureStorage.setTokenExpiry(tokens.expiryDate);
  }

  Future<String?> getAccessToken() => SecureStorage.getAccessToken();
  Future<String?> getRefreshToken() => SecureStorage.getRefreshToken();
  Future<DateTime?> getTokenExpiry() => SecureStorage.getTokenExpiry();

  Future<void> clearTokens() => SecureStorage.clearAll();

  Future<bool> isTokenExpired() => SecureStorage.isTokenExpired();

  // User data operations
  Future<void> saveUser(UserModel user) async {
    // Save to Hive or SharedPreferences
    // For now, we'll use a simple approach
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    final isExpired = await isTokenExpired();
    return !isExpired;
  }
}
```

---

## Step 5: Create Auth Repository Implementation

**File:** `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/token_response.dart';
import '../models/user_model.dart';
import '../models/otp_request.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<void> loginWithEmail(String email, String password) async {
    return handleRequest(
      request: () async {
        final request = LoginRequest(email: email, password: password);
        final response = await _remote.login(request);
        await _saveAuthData(response);
      },
    );
  }

  @override
  Future<void> signupWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    return handleRequest(
      request: () async {
        final request = RegisterRequest(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        );
        final response = await _remote.register(request);
        await _saveAuthData(response);
      },
    );
  }

  @override
  Future<void> loginWithPhone(String phone) async {
    return handleRequest(
      request: () async {
        final request = OtpRequest(phone: phone);
        await _remote.requestPhoneOtp(request);
      },
    );
  }

  @override
  Future<void> verifyOtp(String phone, String otp) async {
    return handleRequest(
      request: () async {
        final request = OtpVerifyRequest(phone: phone, otp: otp);
        final response = await _remote.verifyOtp(request);
        await _saveAuthData(response);
      },
    );
  }

  @override
  Future<void> refreshToken() async {
    final refreshToken = await _local.getRefreshToken();
    if (refreshToken == null) {
      throw UnauthorizedException();
    }

    return handleRequest(
      request: () async {
        final response = await _remote.refreshToken({
          'refresh_token': refreshToken,
        });
        await _saveAuthData(response);
      },
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } finally {
      await _local.clearTokens();
    }
  }

  @override
  Future<Map<String, dynamic>> checkAuthStatus() async {
    final isLoggedIn = await _local.isLoggedIn();
    
    if (isLoggedIn) {
      return {'isAuthenticated': true, 'isGuest': false};
    }

    // Try to refresh token
    final refreshToken = await _local.getRefreshToken();
    if (refreshToken != null) {
      try {
        await this.refreshToken();
        return {'isAuthenticated': true, 'isGuest': false};
      } catch (e) {
        await _local.clearTokens();
      }
    }

    return {'isAuthenticated': false, 'isGuest': false};
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return handleRequest(
      request: () async {
        final response = await _remote.getCurrentUser();
        final user = parseResponse(response);
        await _local.saveUser(user);
        return user;
      },
      fallback: null,
    );
  }

  Future<void> _saveAuthData(ApiResponse<TokenResponse> response) async {
    final tokens = parseResponse(response);
    await _local.saveTokens(tokens);
  }

  @override
  Future<void> loginAsGuest() async {
    // Guest mode doesn't call API
    // Just set a flag in local storage
    // Tokens will have shorter expiry (5 hours)
  }

  @override
  Future<void> verifyEmail(String code) async {
    return handleRequest(
      request: () async {
        await _remote.verify({'code': code});
      },
    );
  }
}
```

---

## Step 6: Create Domain Repository Interface

**File:** `lib/features/auth/domain/repositories/auth_repository.dart`

```dart
abstract class AuthRepository {
  Future<void> loginWithEmail(String email, String password);
  Future<void> signupWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  );
  Future<void> loginWithPhone(String phone);
  Future<void> verifyOtp(String phone, String otp);
  Future<void> verifyEmail(String code);
  Future<void> refreshToken();
  Future<void> logout();
  Future<void> loginAsGuest();
  Future<Map<String, dynamic>> checkAuthStatus();
  Future<dynamic> getCurrentUser();
}
```

---

## Step 7: Create Token Refresh Interceptor

**File:** `lib/core/api/interceptors/token_refresh_interceptor.dart`

```dart
import 'package:dio/dio.dart';
import '../secure_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';

class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  final _pendingRequests = <Function>[];

  TokenRefreshInterceptor(this._dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await SecureStorage.getRefreshToken();
      
      if (refreshToken == null) {
        // No refresh token, logout
        handler.reject(err);
        return;
      }

      if (_isRefreshing) {
        // Queue request
        _pendingRequests.add(() async {
          final token = await SecureStorage.getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
        });
        return;
      }

      _isRefreshing = true;

      try {
        // Refresh token
        final authApi = AuthRemoteDataSource(_dio);
        final response = await authApi.refreshToken({
          'refresh_token': refreshToken,
        });

        final newToken = response.data?.accessToken;
        final newRefreshToken = response.data?.refreshToken;

        if (newToken != null && newRefreshToken != null) {
          await SecureStorage.setAccessToken(newToken);
          await SecureStorage.setRefreshToken(newRefreshToken);

          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);

          // Process queued requests
          for (final request in _pendingRequests) {
            await request();
          }
          _pendingRequests.clear();
        }
      } catch (e) {
        // Refresh failed, clear tokens
        await SecureStorage.clearAll();
        handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.reject(err);
    }
  }
}
```

Update `dio_client.dart` to include this interceptor:

```dart
import 'interceptors/token_refresh_interceptor.dart';

static Dio _createDio() {
  // ... existing code
  
  dio.interceptors.addAll([
    AuthInterceptor(),
    TokenRefreshInterceptor(dio), // Add this
    ErrorInterceptor(),
    if (ApiConfig.enableLogging) LoggingInterceptor(),
  ]);
  
  return dio;
}
```

---

## Step 8: Update Dependency Injection

Update `main.dart` to inject the new repository:

```dart
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

// In main() or a service locator setup:
final dio = DioClient.instance;
final authRemote = AuthRemoteDataSource(dio);
final authLocal = AuthLocalDataSource();
final authRepository = AuthRepositoryImpl(
  remote: authRemote,
  local: authLocal,
);

// Pass to AuthCubit
BlocProvider(
  create: (_) => AuthCubit(authRepository)..checkAuthStatus(),
),
```

---

## Step 9: Update AuthCubit

Update error handling in `AuthCubit` to show user-friendly messages:

```dart
import '../../core/api/api_exceptions.dart';

Future<void> loginWithEmail(String email, String password) async {
  emit(AuthLoading());
  try {
    await _authRepository.loginWithEmail(email, password);
    emit(const AuthAuthenticated(isGuest: false));
  } on ValidationException catch (e) {
    emit(AuthError(e.message));
  } on UnauthorizedException catch (e) {
    emit(AuthError(e.message));
  } on NetworkException catch (e) {
    emit(AuthError(e.message));
  } catch (e) {
    emit(AuthError('Une erreur est survenue. Réessayez.'));
  }
}
```

---

## Checklist

- [ ] All DTO models created
- [ ] Code generation run successfully
- [ ] AuthRemoteDataSource created with Retrofit
- [ ] AuthLocalDataSource implemented
- [ ] AuthRepositoryImpl created
- [ ] Domain repository interface defined
- [ ] TokenRefreshInterceptor implemented
- [ ] DioClient updated with new interceptor
- [ ] AuthCubit updated with proper error handling
- [ ] main.dart updated with dependency injection
- [ ] Login flow tested
- [ ] OTP flow tested
- [ ] Token refresh tested

---

## Testing

### Unit Tests

**File:** `test/features/auth/auth_repository_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:abdoul_express/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;
  late MockAuthLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockLocal = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remote: mockRemote,
      local: mockLocal,
    );
  });

  group('loginWithEmail', () {
    test('should save tokens on successful login', () async {
      // Arrange
      final response = ApiResponse(
        success: true,
        data: TokenResponse(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresIn: 900,
        ),
      );
      when(() => mockRemote.login(any())).thenAnswer((_) async => response);

      // Act
      await repository.loginWithEmail('test@test.com', 'password');

      // Assert
      verify(() => mockLocal.saveTokens(any())).called(1);
    });
  });
}
```

---

## Next Phase

➡️ [Phase 3: Product Catalog](./03-products.md)
