import 'package:dio/dio.dart';

/// Base API exception
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Network-related exceptions (no internet, timeout, etc.)
class NetworkException extends ApiException {
  NetworkException(super.message);

  factory NetworkException.noInternet() {
    return NetworkException('No internet connection. Please check your network.');
  }

  factory NetworkException.timeout() {
    return NetworkException('Request timeout. Please try again.');
  }

  factory NetworkException.connectionFailed() {
    return NetworkException('Connection failed. Please try again.');
  }
}

/// Authentication exceptions (401, 403)
class AuthException extends ApiException {
  AuthException(
    super.message, {
    super.statusCode,
    super.data,
  });

  factory AuthException.unauthorized() {
    return AuthException(
      'Session expired. Please login again.',
      statusCode: 401,
    );
  }

  factory AuthException.forbidden() {
    return AuthException(
      'Access denied. You do not have permission to perform this action.',
      statusCode: 403,
    );
  }

  factory AuthException.invalidCredentials() {
    return AuthException(
      'Invalid email or password.',
      statusCode: 401,
    );
  }
}

/// Validation exceptions (400)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException(
    super.message, {
    this.errors,
    super.data,
  }) : super(statusCode: 400);

  factory ValidationException.fromResponse(dynamic response) {
    String message = 'Validation failed';
    Map<String, dynamic>? errors;

    if (response is Map<String, dynamic>) {
      message = response['message'] ?? message;
      if (response['errors'] is Map<String, dynamic>) {
        errors = response['errors'] as Map<String, dynamic>;
      }
    }

    return ValidationException(message, errors: errors, data: response);
  }

  /// Get error message for a specific field
  String? getFieldError(String field) {
    if (errors == null) return null;
    final fieldError = errors![field];
    if (fieldError is List && fieldError.isNotEmpty) {
      return fieldError.first.toString();
    }
    return fieldError?.toString();
  }

  /// Get all error messages as a single string
  String getAllErrors() {
    if (errors == null || errors!.isEmpty) return message;

    final errorMessages = <String>[];
    errors!.forEach((field, value) {
      if (value is List) {
        errorMessages.addAll(value.map((e) => e.toString()));
      } else {
        errorMessages.add(value.toString());
      }
    });

    return errorMessages.join('\n');
  }
}

/// Resource not found exception (404)
class NotFoundException extends ApiException {
  NotFoundException(super.message)
      : super(statusCode: 404);

  factory NotFoundException.resource(String resourceType) {
    return NotFoundException('$resourceType not found.');
  }
}

/// Server exceptions (500+)
class ServerException extends ApiException {
  ServerException(
    super.message, {
    super.statusCode,
    super.data,
  });

  factory ServerException.internal() {
    return ServerException(
      'Server error occurred. Please try again later.',
      statusCode: 500,
    );
  }

  factory ServerException.serviceUnavailable() {
    return ServerException(
      'Service temporarily unavailable. Please try again later.',
      statusCode: 503,
    );
  }
}

/// Conflict exception (409) - e.g., duplicate email
class ConflictException extends ApiException {
  ConflictException(super.message)
      : super(statusCode: 409);

  factory ConflictException.duplicate(String resource) {
    return ConflictException('$resource already exists.');
  }
}

/// Too many requests exception (429)
class RateLimitException extends ApiException {
  final int? retryAfter;

  RateLimitException(
    super.message, {
    this.retryAfter,
  }) : super(statusCode: 429);

  factory RateLimitException.tooManyRequests([int? retryAfter]) {
    return RateLimitException(
      'Too many requests. Please try again later.',
      retryAfter: retryAfter,
    );
  }
}

/// Generic/unknown API exception
class UnknownApiException extends ApiException {
  UnknownApiException(
    super.message, {
    super.statusCode,
    super.data,
  });
}

/// Utility class to parse Dio errors into ApiException
class ApiExceptionHandler {
  static ApiException handle(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    return UnknownApiException(
      error.toString(),
    );
  }

  static ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();

      case DioExceptionType.connectionError:
        return NetworkException.connectionFailed();

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return UnknownApiException('Request cancelled');

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return NetworkException.noInternet();
        }
        return UnknownApiException(
          error.message ?? 'Unknown error occurred',
        );

      default:
        return UnknownApiException(
          error.message ?? 'Unknown error occurred',
        );
    }
  }

  static ApiException _handleResponseError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Extract message from response
    String message = 'An error occurred';
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? message;
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return ValidationException.fromResponse(data);

      case 401:
        return AuthException(message, statusCode: 401, data: data);

      case 403:
        return AuthException.forbidden();

      case 404:
        return NotFoundException(message);

      case 409:
        return ConflictException(message);

      case 429:
        final retryAfter = response?.headers['retry-after']?.first;
        return RateLimitException.tooManyRequests(
          retryAfter != null ? int.tryParse(retryAfter) : null,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(message, statusCode: statusCode, data: data);

      default:
        return UnknownApiException(
          message,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// Get user-friendly message from exception
  static String getUserMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'An unexpected error occurred';
  }
}
