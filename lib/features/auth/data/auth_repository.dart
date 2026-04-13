import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/interceptors/auth_interceptor.dart';
import 'models/auth_response.dart';
import 'models/login_request.dart';
import 'models/phone_auth_request.dart';
import 'models/password_request.dart';
import 'models/register_request.dart';
import 'models/update_profile_request.dart';
import 'models/user_model.dart';

/// Repository for authentication operations
/// Handles user login, registration, phone auth, guest sessions, and profile management
class AuthRepository {
  late final ApiClient _apiClient;
  late final SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize the repository
  /// Must be called before using any methods
  Future<void> initialize() async {
    if (_initialized) return;
    _apiClient = await ApiClient.getInstance();
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Check current authentication status
  Future<Map<String, dynamic>> checkAuthStatus() async {
    await initialize();

    final isAuth = await AuthInterceptor.isAuthenticated();
    final isGuest = await AuthInterceptor.isGuest();
    final token = await AuthInterceptor.getAccessToken();

    return {
      'isAuthenticated': isAuth || isGuest,
      'isGuest': isGuest,
      'hasToken': token != null,
    };
  }

  /// Login with email and password
  Future<AuthResponse> loginWithEmail(String email, String password) async {
    await initialize();

    final request = LoginRequest(
      email: email,
      password: password,
    );

    final response = await _apiClient.post(
      ApiConfig.loginEndpoint,
      data: request.toJson(),
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    final authResponse = AuthResponse.fromJson(data);

    // Save tokens (refreshToken is optional — backend may not send it)
    await AuthInterceptor.saveTokens(
      _prefs,
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    return authResponse;
  }

  /// Register with email, password, firstName, lastName
  Future<AuthResponse> signupWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    await initialize();

    final request = RegisterRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    final response = await _apiClient.post(
      ApiConfig.registerEndpoint,
      data: request.toJson(),
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    final authResponse = AuthResponse.fromJson(data);

    // Save tokens (refreshToken is optional — backend may not send it)
    await AuthInterceptor.saveTokens(
      _prefs,
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    return authResponse;
  }

  /// Initiate phone authentication (send OTP)
  Future<PhoneAuthInitiateResponse> loginWithPhone(String phoneNumber) async {
    await initialize();

    final request = PhoneAuthInitiateRequest(phoneNumber: phoneNumber);

    final response = await _apiClient.post(
      ApiConfig.phoneInitiateEndpoint,
      data: request.toJson(),
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return PhoneAuthInitiateResponse.fromJson(data);
  }

  /// Verify OTP and complete phone authentication
  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    await initialize();

    final request = PhoneAuthVerifyRequest(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );

    final response = await _apiClient.post(
      ApiConfig.phoneVerifyEndpoint,
      data: request.toJson(),
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    final authResponse = AuthResponse.fromJson(data);

    // Save tokens (refreshToken is optional)
    await AuthInterceptor.saveTokens(
      _prefs,
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    return authResponse;
  }

  /// Login as guest (anonymous user)
  Future<GuestResponse> loginAsGuest() async {
    await initialize();

    final response = await _apiClient.post(
      ApiConfig.guestEndpoint,
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    final guestResponse = GuestResponse.fromJson(data);

    // Save session ID for guest
    await AuthInterceptor.saveSessionId(
      _prefs,
      guestResponse.sessionId,
    );

    return guestResponse;
  }

  /// Get current user profile
  Future<UserModel> getProfile() async {
    await initialize();

    final response = await _apiClient.get(
      ApiConfig.profileEndpoint,
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return UserModel.fromJson(data);
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? avatar,
  }) async {
    await initialize();

    final request = UpdateProfileRequest(
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
    );

    final response = await _apiClient.put(
      ApiConfig.profileEndpoint,
      data: request.toJson(),
    );

    final data = _apiClient.parseResponse<Map<String, dynamic>>(response);
    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return UserModel.fromJson(data);
  }

  /// Change password (for authenticated users)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await initialize();

    final request = ChangePasswordRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    await _apiClient.post(
      ApiConfig.changePasswordEndpoint,
      data: request.toJson(),
    );
  }

  /// Request password reset (send OTP to email)
  Future<void> forgotPassword(String email) async {
    await initialize();

    final request = ForgotPasswordRequest(email: email);

    await _apiClient.post(
      ApiConfig.forgotPasswordEndpoint,
      data: request.toJson(),
    );
  }

  /// Verify OTP and reset password
  Future<void> verifyResetOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await initialize();

    final request = VerifyResetOtpRequest(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );

    await _apiClient.post(
      ApiConfig.verifyResetOtpEndpoint,
      data: request.toJson(),
    );
  }

  /// Logout user (clear local auth data)
  Future<void> logout() async {
    await initialize();

    try {
      // Try to call logout endpoint
      await _apiClient.post(ApiConfig.logoutEndpoint);
    } catch (e) {
      // Continue even if API call fails
    }

    // Clear local auth data
    await AuthInterceptor.clearAuth();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    await initialize();
    return AuthInterceptor.isAuthenticated();
  }

  /// Check if user is guest
  Future<bool> isGuest() async {
    await initialize();
    return AuthInterceptor.isGuest();
  }
}
