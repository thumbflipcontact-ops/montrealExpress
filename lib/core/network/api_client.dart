import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';
import 'exceptions/api_exception.dart';
import 'interceptors/auth_interceptor.dart';

/// Singleton API client for making HTTP requests to the backend
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  late final SharedPreferences _prefs;

  ApiClient._internal(SharedPreferences prefs) {
    _prefs = prefs;
    _dio = Dio(_getBaseOptions());
    _setupInterceptors();
  }

  /// Get singleton instance of ApiClient
  static Future<ApiClient> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = ApiClient._internal(prefs);
    }
    return _instance!;
  }

  /// Get base Dio options
  BaseOptions _getBaseOptions() {
    return BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
      headers: {
        ApiConfig.contentTypeHeader: ApiConfig.contentTypeJson,
        ApiConfig.acceptHeader: ApiConfig.acceptJson,
      },
      validateStatus: (status) {
        // Accept all status codes, we'll handle errors in interceptor
        return status != null && status < 500;
      },
    );
  }

  /// Setup interceptors for Dio
  void _setupInterceptors() {
    // Auth interceptor (must be first to add tokens)
    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        prefs: _prefs,
      ),
    );

    // Logging interceptor (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Error handling interceptor
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (error, handler) {
          final apiException = ApiExceptionHandler.handle(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiException,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  /// Get Dio instance for direct access if needed
  Dio get dio => _dio;

  // ============ HTTP Methods ============

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// Upload file
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  /// Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  // ============ Helper Methods ============

  /// Parse API response and extract data
  T? parseResponse<T>(Response response) {
    if (response.data is Map<String, dynamic>) {
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return responseData['data'] as T?;
      }
    }
    return null;
  }

  /// Check if response is successful
  bool isSuccessful(Response response) {
    if (response.data is Map<String, dynamic>) {
      final responseData = response.data as Map<String, dynamic>;
      return responseData['success'] == true;
    }
    return false;
  }

  /// Get error message from response
  String? getErrorMessage(Response response) {
    if (response.data is Map<String, dynamic>) {
      final responseData = response.data as Map<String, dynamic>;
      return responseData['message'] as String?;
    }
    return null;
  }
}
