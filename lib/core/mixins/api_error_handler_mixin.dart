import 'package:flutter/material.dart';
import '../network/exceptions/api_exception.dart';
import '../widgets/api_error_dialog.dart';

/// Mixin to handle API errors in widgets
///
/// Usage:
/// ```dart
/// class MyPage extends StatefulWidget {
///   // ...
/// }
///
/// class _MyPageState extends State<MyPage> with ApiErrorHandlerMixin {
///   Future<void> _loadData() async {
///     await handleApiCall(
///       context: context,
///       apiCall: () async {
///         final client = await ApiClient.getInstance();
///         final response = await client.get('/api/data');
///         // Process response...
///       },
///     );
///   }
/// }
/// ```
mixin ApiErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  /// Handle an API call with automatic error handling
  ///
  /// Shows an error dialog if the API call fails and provides retry functionality.
  /// Returns true if the API call succeeded, false otherwise.
  Future<bool> handleApiCall({
    required BuildContext context,
    required Future<void> Function() apiCall,
    VoidCallback? onSuccess,
    VoidCallback? onCancel,
    String? errorTitle,
    bool showLoadingIndicator = false,
  }) async {
    try {
      if (showLoadingIndicator) {
        _showLoadingDialog(context);
      }

      await apiCall();

      if (showLoadingIndicator && context.mounted) {
        Navigator.of(context).pop();
      }

      onSuccess?.call();
      return true;
    } on ApiException catch (e) {
      if (showLoadingIndicator && context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        await _showErrorDialog(
          context: context,
          exception: e,
          onRetry: () => handleApiCall(
            context: context,
            apiCall: apiCall,
            onSuccess: onSuccess,
            onCancel: onCancel,
            errorTitle: errorTitle,
            showLoadingIndicator: showLoadingIndicator,
          ),
          onCancel: onCancel,
          errorTitle: errorTitle,
        );
      }

      return false;
    } catch (e) {
      if (showLoadingIndicator && context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        await _showErrorDialog(
          context: context,
          exception: UnknownApiException(e.toString()),
          onRetry: () => handleApiCall(
            context: context,
            apiCall: apiCall,
            onSuccess: onSuccess,
            onCancel: onCancel,
            errorTitle: errorTitle,
            showLoadingIndicator: showLoadingIndicator,
          ),
          onCancel: onCancel,
          errorTitle: errorTitle,
        );
      }

      return false;
    }
  }

  /// Handle an API call that returns data
  ///
  /// Shows an error dialog if the API call fails and provides retry functionality.
  /// Returns the data if successful, null otherwise.
  Future<R?> handleApiCallWithData<R>({
    required BuildContext context,
    required Future<R> Function() apiCall,
    void Function(R data)? onSuccess,
    VoidCallback? onCancel,
    String? errorTitle,
    bool showLoadingIndicator = false,
  }) async {
    try {
      if (showLoadingIndicator) {
        _showLoadingDialog(context);
      }

      final result = await apiCall();

      if (showLoadingIndicator && context.mounted) {
        Navigator.of(context).pop();
      }

      onSuccess?.call(result);
      return result;
    } on ApiException catch (e) {
      if (showLoadingIndicator && context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        await _showErrorDialog(
          context: context,
          exception: e,
          onRetry: () => handleApiCallWithData<R>(
            context: context,
            apiCall: apiCall,
            onSuccess: onSuccess,
            onCancel: onCancel,
            errorTitle: errorTitle,
            showLoadingIndicator: showLoadingIndicator,
          ),
          onCancel: onCancel,
          errorTitle: errorTitle,
        );
      }

      return null;
    } catch (e) {
      if (showLoadingIndicator && context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        await _showErrorDialog(
          context: context,
          exception: UnknownApiException(e.toString()),
          onRetry: () => handleApiCallWithData<R>(
            context: context,
            apiCall: apiCall,
            onSuccess: onSuccess,
            onCancel: onCancel,
            errorTitle: errorTitle,
            showLoadingIndicator: showLoadingIndicator,
          ),
          onCancel: onCancel,
          errorTitle: errorTitle,
        );
      }

      return null;
    }
  }

  Future<void> _showErrorDialog({
    required BuildContext context,
    required ApiException exception,
    required VoidCallback onRetry,
    VoidCallback? onCancel,
    String? errorTitle,
  }) async {
    await ApiErrorDialog.show(
      context: context,
      exception: exception,
      onRetry: onRetry,
      onCancel: onCancel,
      title: errorTitle,
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show a simple error snackbar (alternative to dialog for minor errors)
  void showErrorSnackBar(BuildContext context, ApiException exception) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exception.message),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}