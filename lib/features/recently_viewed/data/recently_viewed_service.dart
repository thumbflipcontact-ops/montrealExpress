import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../model/product.dart';

class RecentlyViewedService {
  static const String _key = 'recently_viewed_products';
  static const int _maxItems = 20;

  static Future<List<Product>> getRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    try {
      return data
        .map((json) {
          try {
            final productMap = jsonDecode(json) as Map<String, dynamic>;
            return Product.fromJson(productMap);
          } catch (e) {
            // Skip invalid entries
            return null;
          }
        })
        .where((product) => product != null)
        .cast<Product>()
        .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addToRecentlyViewed(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    // Convert product to JSON using generated toJson method
    final productJson = jsonEncode(product.toJson());

    // Remove if already exists
    data.removeWhere((item) {
      try {
        final existingMap = jsonDecode(item) as Map<String, dynamic>;
        return existingMap['id'] == product.id;
      } catch (e) {
        return false;
      }
    });

    // Add to beginning
    data.insert(0, productJson);

    // Keep only max items
    if (data.length > _maxItems) {
      data.removeRange(_maxItems, data.length);
    }

    await prefs.setStringList(_key, data);
  }

  static Future<void> clearRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> removeProduct(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    data.removeWhere((item) {
      try {
        final existingMap = jsonDecode(item) as Map<String, dynamic>;
        return existingMap['id'] == productId;
      } catch (e) {
        return true; // Remove invalid entries
      }
    });

    await prefs.setStringList(_key, data);
  }

  static Stream<List<Product>> watchRecentlyViewed() {
    // Create a stream that emits updates when the recently viewed list changes
    // This is a simplified implementation - in a real app, you'd use a proper state management solution
    return Stream.periodic(const Duration(seconds: 1), (_) async {
      return await getRecentlyViewed();
    }).asyncMap((future) => future);
  }
}