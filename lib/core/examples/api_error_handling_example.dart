import 'package:abdoul_express/core/widgets/api_error_dialog.dart' show ApiErrorDialog;
import 'package:flutter/material.dart';
import '../mixins/api_error_handler_mixin.dart';
import '../network/api_client.dart';
import '../network/exceptions/api_exception.dart';

/// Example page showing how to use the API error handling mixin
///
/// This example demonstrates:
/// 1. Basic API call with error handling and retry
/// 2. API call that returns data
/// 3. API call with loading indicator
/// 4. Manual error dialog showing
/// 5. Error snackbar for minor errors
class ApiErrorHandlingExamplePage extends StatefulWidget {
  const ApiErrorHandlingExamplePage({super.key});

  @override
  State<ApiErrorHandlingExamplePage> createState() =>
      _ApiErrorHandlingExamplePageState();
}

class _ApiErrorHandlingExamplePageState
    extends State<ApiErrorHandlingExamplePage> with ApiErrorHandlerMixin {
  List<String> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// Example 1: Basic API call with automatic error handling and retry
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    final success = await handleApiCall(
      context: context,
      apiCall: () async {
        final client = await ApiClient.getInstance();
        final response = await client.get('/products');

        // Extract data from response
        final data = client.parseResponse(response);
        if (data is List) {
          setState(() {
            _products = data.map((e) => e.toString()).toList();
          });
        }
      },
      onSuccess: () {
        // Optional: Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Products loaded successfully!')),
        );
      },
      onCancel: () {
        // Optional: Handle cancel action
        Navigator.of(context).pop();
      },
    );

    setState(() => _isLoading = false);

    if (success) {
      // API call succeeded
      print('Products loaded successfully');
    } else {
      // API call failed after retry
      print('Failed to load products');
    }
  }

  /// Example 2: API call that returns data
  Future<void> _loadProductDetails(String productId) async {
    final productData = await handleApiCallWithData<Map<String, dynamic>>(
      context: context,
      apiCall: () async {
        final client = await ApiClient.getInstance();
        final response = await client.get('/products/$productId');
        return client.parseResponse(response) ?? {};
      },
      onSuccess: (data) {
        // Use the returned data
        print('Product data: $data');
      },
      showLoadingIndicator: true,
      errorTitle: 'Failed to Load Product',
    );

    if (productData != null) {
      // Use the product data
      print('Product name: ${productData['name']}');
    }
  }

  /// Example 3: Delete operation with confirmation
  Future<void> _deleteProduct(String productId) async {
    // First show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Then perform delete with error handling
    await handleApiCall(
      context: context,
      apiCall: () async {
        final client = await ApiClient.getInstance();
        await client.delete('/products/$productId');
      },
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
        _loadProducts(); // Reload the list
      },
      showLoadingIndicator: true,
      errorTitle: 'Failed to Delete Product',
    );
  }

  /// Example 4: Manual error handling (for complex scenarios)
  Future<void> _manualErrorHandling() async {
    try {
      final client = await ApiClient.getInstance();
      final response = await client.post(
        '/custom-endpoint',
        data: {'key': 'value'},
      );

      // Process response...
    } on ApiException catch (e) {
      if (mounted) {
        // Use the error dialog manually
        await ApiErrorDialog.show(
          context: context,
          exception: e,
          onRetry: _manualErrorHandling,
          title: 'Custom Error Title',
        );
      }
    }
  }

  /// Example 5: Show error as snackbar (for minor errors)
  Future<void> _minorOperation() async {
    try {
      final client = await ApiClient.getInstance();
      await client.post('/minor-operation');
    } on ApiException catch (e) {
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Error Handling Example'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'This page demonstrates API error handling with automatic retry functionality.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadProducts,
                  child: const Text('Reload Products (Example 1)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _loadProductDetails('123'),
                  child: const Text('Load Product Details (Example 2)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _deleteProduct('123'),
                  child: const Text('Delete Product (Example 3)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _manualErrorHandling,
                  child: const Text('Manual Error Handling (Example 4)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _minorOperation,
                  child: const Text('Minor Operation with Snackbar (Example 5)'),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Products (${_products.length}):',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._products.map(
                  (product) => Card(
                    child: ListTile(
                      title: Text(product),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProduct(product),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}