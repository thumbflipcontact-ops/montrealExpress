import 'package:flutter/material.dart';
import '../network/exceptions/api_exception.dart';

/// Reusable dialog for displaying API errors with retry functionality
class ApiErrorDialog extends StatelessWidget {
  final ApiException exception;
  final VoidCallback onRetry;
  final VoidCallback? onCancel;
  final String? title;

  const ApiErrorDialog({
    super.key,
    required this.exception,
    required this.onRetry,
    this.onCancel,
    this.title,
  });

  /// Show the error dialog
  static Future<bool?> show({
    required BuildContext context,
    required ApiException exception,
    required VoidCallback onRetry,
    VoidCallback? onCancel,
    String? title,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApiErrorDialog(
        exception: exception,
        onRetry: onRetry,
        onCancel: onCancel,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            _getIconForException(),
            color: _getColorForException(theme),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title ?? _getTitleForException(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getMessageForException(),
            style: theme.textTheme.bodyMedium,
          ),
          if (exception is ValidationException) ...[
            const SizedBox(height: 16),
            _buildValidationErrors(context),
          ],
          if (exception.statusCode != null) ...[
            const SizedBox(height: 12),
            Text(
              'Error Code: ${exception.statusCode}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (onCancel != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              onCancel?.call();
            },
            child: const Text('Cancel'),
          ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(true);
            onRetry();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildValidationErrors(BuildContext context) {
    final validationException = exception as ValidationException;
    final errors = validationException.errors;

    if (errors == null || errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: errors.entries.map((entry) {
          final fieldErrors = entry.value is List
              ? (entry.value as List).map((e) => e.toString()).toList()
              : [entry.value.toString()];

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: fieldErrors
                        .map((error) => Text(
                              error,
                              style: Theme.of(context).textTheme.bodySmall,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForException() {
    if (exception is NetworkException) {
      return Icons.wifi_off;
    } else if (exception is AuthException) {
      return Icons.lock_outline;
    } else if (exception is ValidationException) {
      return Icons.warning_amber;
    } else if (exception is NotFoundException) {
      return Icons.search_off;
    } else if (exception is ServerException) {
      return Icons.cloud_off;
    } else if (exception is RateLimitException) {
      return Icons.timer_outlined;
    } else {
      return Icons.error_outline;
    }
  }

  Color _getColorForException(ThemeData theme) {
    if (exception is NetworkException) {
      return Colors.orange;
    } else if (exception is AuthException) {
      return Colors.amber;
    } else if (exception is ServerException) {
      return Colors.purple;
    } else {
      return theme.colorScheme.error;
    }
  }

  String _getTitleForException() {
    if (exception is NetworkException) {
      return 'Connection Error';
    } else if (exception is AuthException) {
      return 'Authentication Error';
    } else if (exception is ValidationException) {
      return 'Validation Error';
    } else if (exception is NotFoundException) {
      return 'Not Found';
    } else if (exception is ServerException) {
      return 'Server Error';
    } else if (exception is ConflictException) {
      return 'Conflict';
    } else if (exception is RateLimitException) {
      return 'Too Many Requests';
    } else {
      return 'Error';
    }
  }

  String _getMessageForException() {
    return exception.message;
  }
}