import 'package:abdoul_express/model/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CartItem {
  CartItem({required this.product, this.quantity = 1});
  final Product product;
  int quantity;

  double get total => product.price * quantity;
}

class AppController extends ChangeNotifier {
  final Map<String, CartItem> _cart = {};
  final Set<String> _favorites = {};

  List<CartItem> get cartItems => _cart.values.toList(growable: false);
  Set<String> get favorites => _favorites;

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('📦 [AppController] $message');
    }
  }

  bool isFavorite(String productId) => _favorites.contains(productId);

  void toggleFavorite(Product p) {
    if (_favorites.contains(p.id)) {
      _favorites.remove(p.id);
    } else {
      _favorites.add(p.id);
    }
    notifyListeners();
  }

  void addToCart(Product p, {int quantity = 1}) {
    _logDebug('Adding to cart: ${p.title} (x$quantity) @ ${p.price} F CFA');

    final item = _cart[p.id];
    if (item == null) {
      _cart[p.id] = CartItem(product: p, quantity: quantity);
      _logDebug('New item added. Cart now has ${_cart.length} unique items');
    } else {
      final oldQty = item.quantity;
      item.quantity += quantity;
      _logDebug('Updated existing item from $oldQty to ${item.quantity}');
    }

    notifyListeners();
    _logDebug('Cart totals - Items: $cartCount, Subtotal: ${subtotal.toStringAsFixed(0)} F CFA, Total: ${total.toStringAsFixed(0)} F CFA');
  }

  void removeFromCart(String productId) {
    final item = _cart[productId];
    if (item != null) {
      _logDebug('Removing from cart: ${item.product.title} (Product ID: $productId)');
      _cart.remove(productId);
      notifyListeners();
      _logDebug('Item removed. Cart now has ${_cart.length} unique items, $cartCount total items');
    } else {
      _logDebug('⚠️ Attempted to remove non-existent item: $productId');
    }
  }

  void setQuantity(String productId, int quantity) {
    final item = _cart[productId];
    _logDebug('Setting quantity for Product ID $productId to $quantity');

    if (quantity <= 0) {
      if (item != null) {
        _logDebug('Quantity is 0 or less, removing ${item.product.title}');
      }
      _cart.remove(productId);
    } else {
      if (item != null) {
        final oldQty = item.quantity;
        item.quantity = quantity;
        _logDebug('Updated ${item.product.title} quantity from $oldQty to $quantity');
      } else {
        _logDebug('⚠️ Attempted to set quantity for non-existent item: $productId');
      }
    }

    notifyListeners();
    _logDebug('Cart totals - Items: $cartCount, Subtotal: ${subtotal.toStringAsFixed(0)} F CFA, Total: ${total.toStringAsFixed(0)} F CFA');
  }

  int get cartCount => _cart.values.fold(0, (sum, it) => sum + it.quantity);
  double get subtotal => _cart.values.fold(0, (sum, it) => sum + it.total);
  double get shipping => _cart.isEmpty ? 0 : 1000.0; // Fixed shipping cost in F CFA
  double get total => subtotal + shipping;
}

class AppState extends InheritedNotifier<AppController> {
  const AppState({super.key, required super.child, required AppController controller})
      : super(notifier: controller);

  static AppController of(BuildContext context) {
    final state = context.dependOnInheritedWidgetOfExactType<AppState>();
    assert(state != null, 'AppState not found in context');
    return state!.notifier!;
  }
}
