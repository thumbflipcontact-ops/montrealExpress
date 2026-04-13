import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:abdoul_express/core/app_state.dart';
import 'package:abdoul_express/core/utils/offline_action_queue.dart';
import 'package:abdoul_express/model/cart.dart';
import '../../data/data_sources/cart_remote_data_source.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({
    AppController? controller,
    CartRemoteDataSource? cartDataSource,
  })  : _controller = controller,
        _cartDataSource = cartDataSource,
        super(CartState.initial()) {
    _initialize();
  }

  final AppController? _controller;
  final CartRemoteDataSource? _cartDataSource;
  Cart? _currentCart;

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('🛒 [CartCubit] $message');
    }
  }

  /// Initialize cart - load from API or fallback to local
  Future<void> _initialize() async {
    _logDebug('CartCubit initializing');

    // Try to load from API first
    if (_cartDataSource != null) {
      await loadCart();
    } else if (_controller != null) {
      // Fallback to local controller (backward compatibility)
      _syncFromController();
    }

    _logDebug('CartCubit initialized');
  }

  /// Load cart from API
  Future<void> loadCart() async {
    if (_cartDataSource == null) {
      _logDebug('No cart data source available, using local cart');
      if (_controller != null) _syncFromController();
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _cartDataSource.initialize();
      final cart = await _cartDataSource.getCart();
      _currentCart = cart;

      // Convert API cart items to local CartItem for compatibility
      final cartItems = cart.items.map((item) {
        return CartItem(
          product: item.product,
          quantity: item.quantity,
        );
      }).toList();

      emit(CartState(
        items: cartItems,
        isLoading: false,
        subtotal: cart.subtotal,
        tax: cart.tax,
        discount: cart.discount,
        total: cart.total,
        couponCode: cart.couponCode,
      ));

      _logDebug('Cart loaded: ${cartItems.length} items, total: ${cart.total} F CFA');
    } catch (e) {
      _logDebug('Error loading cart: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load cart: $e',
      ));

      // Fallback to local controller if available
      if (_controller != null) {
        _syncFromController();
      }
    }
  }

  /// Sync from local controller (backward compatibility)
  void _syncFromController() {
    if (_controller == null) return;

    final items = _controller.cartItems.map((item) {
      return CartItem(product: item.product, quantity: item.quantity);
    }).toList();

    emit(CartState(
      items: items,
      subtotal: _controller.subtotal,
      total: _controller.subtotal,
    ));

    _logDebug('Synced from controller: ${items.length} items');
  }

  /// Add item to cart
  Future<void> addToCart(CartItem item) async {
    _logDebug('Adding to cart: ${item.product.title} (x${item.quantity})');

    if (_cartDataSource != null) {
      // Use API
      emit(state.copyWith(isLoading: true, error: null));

      try {
        await _cartDataSource.initialize();
        final cart = await _cartDataSource.addToCart(
          productId: item.product.id,
          quantity: item.quantity,
        );
        _currentCart = cart;

        final cartItems = cart.items.map((item) {
          return CartItem(product: item.product, quantity: item.quantity);
        }).toList();

        emit(CartState(
          items: cartItems,
          isLoading: false,
          subtotal: cart.subtotal,
          tax: cart.tax,
          discount: cart.discount,
          total: cart.total,
          couponCode: cart.couponCode,
        ));

        _logDebug('Item added via API. Total: ${cart.total} F CFA');
      } catch (e) {
        _logDebug('Error adding to cart: $e');
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to add item: $e',
        ));
      }
    } else if (_controller != null) {
      // Fallback to local controller
      offlineQueue.add(OfflineAction(
        id: 'add-${item.product.id}',
        action: () async {
          _controller.addToCart(item.product, quantity: item.quantity);
        },
      ));

      _controller.addToCart(item.product, quantity: item.quantity);
      _syncFromController();
      _logDebug('Item added locally');
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String productId) async {
    _logDebug('Removing from cart: Product ID $productId');

    if (_cartDataSource != null && _currentCart != null) {
      // Find cart item ID
      final cartItem = _currentCart!.items.firstWhere(
        (item) => item.product.id == productId,
        orElse: () => _currentCart!.items.first,
      );

      emit(state.copyWith(isLoading: true, error: null));

      try {
        final cart = await _cartDataSource.removeCartItem(cartItem.id);
        _currentCart = cart;

        final cartItems = cart.items.map((item) {
          return CartItem(product: item.product, quantity: item.quantity);
        }).toList();

        emit(CartState(
          items: cartItems,
          isLoading: false,
          subtotal: cart.subtotal,
          tax: cart.tax,
          discount: cart.discount,
          total: cart.total,
          couponCode: cart.couponCode,
        ));

        _logDebug('Item removed via API');
      } catch (e) {
        _logDebug('Error removing from cart: $e');
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to remove item: $e',
        ));
      }
    } else if (_controller != null) {
      _controller.removeFromCart(productId);
      _syncFromController();
      _logDebug('Item removed locally');
    }
  }

  /// Set item quantity
  Future<void> setQuantity(String productId, int quantity) async {
    _logDebug('Setting quantity for $productId: $quantity');

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    if (_cartDataSource != null && _currentCart != null) {
      final cartItem = _currentCart!.items.firstWhere(
        (item) => item.product.id == productId,
        orElse: () => _currentCart!.items.first,
      );

      emit(state.copyWith(isLoading: true, error: null));

      try {
        final cart = await _cartDataSource.updateCartItem(
          itemId: cartItem.id,
          quantity: quantity,
        );
        _currentCart = cart;

        final cartItems = cart.items.map((item) {
          return CartItem(product: item.product, quantity: item.quantity);
        }).toList();

        emit(CartState(
          items: cartItems,
          isLoading: false,
          subtotal: cart.subtotal,
          tax: cart.tax,
          discount: cart.discount,
          total: cart.total,
          couponCode: cart.couponCode,
        ));

        _logDebug('Quantity updated via API');
      } catch (e) {
        _logDebug('Error updating quantity: $e');
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to update quantity: $e',
        ));
      }
    } else if (_controller != null) {
      _controller.setQuantity(productId, quantity);
      _syncFromController();
      _logDebug('Quantity updated locally');
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    _logDebug('Clearing entire cart');

    if (_cartDataSource != null) {
      emit(state.copyWith(isLoading: true, error: null));

      try {
        await _cartDataSource.clearCart();
        _currentCart = null;

        emit(CartState.initial());
        _logDebug('Cart cleared via API');
      } catch (e) {
        _logDebug('Error clearing cart: $e');
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to clear cart: $e',
        ));
      }
    } else if (_controller != null) {
      final itemIds = _controller.cartItems.map((item) => item.product.id).toList();
      for (final id in itemIds) {
        _controller.removeFromCart(id);
      }
      _syncFromController();
      _logDebug('Cart cleared locally');
    }
  }

  /// Apply coupon
  Future<void> applyCoupon(String couponCode) async {
    _logDebug('Applying coupon: $couponCode');

    if (_cartDataSource == null) {
      emit(state.copyWith(error: 'Coupon feature requires API connection'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final cart = await _cartDataSource.applyCoupon(couponCode);
      _currentCart = cart;

      final cartItems = cart.items.map((item) {
        return CartItem(product: item.product, quantity: item.quantity);
      }).toList();

      emit(CartState(
        items: cartItems,
        isLoading: false,
        subtotal: cart.subtotal,
        tax: cart.tax,
        discount: cart.discount,
        total: cart.total,
        couponCode: cart.couponCode,
      ));

      _logDebug('Coupon applied: ${cart.couponCode}, discount: ${cart.discount}');
    } catch (e) {
      _logDebug('Error applying coupon: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to apply coupon: $e',
      ));
    }
  }

  /// Remove coupon
  Future<void> removeCoupon() async {
    _logDebug('Removing coupon');

    if (_cartDataSource == null) return;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final cart = await _cartDataSource.removeCoupon();
      _currentCart = cart;

      final cartItems = cart.items.map((item) {
        return CartItem(product: item.product, quantity: item.quantity);
      }).toList();

      emit(CartState(
        items: cartItems,
        isLoading: false,
        subtotal: cart.subtotal,
        tax: cart.tax,
        discount: cart.discount,
        total: cart.total,
      ));

      _logDebug('Coupon removed');
    } catch (e) {
      _logDebug('Error removing coupon: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to remove coupon: $e',
      ));
    }
  }

  /// Validate cart before checkout
  Future<CartValidation?> validateCart() async {
    _logDebug('Validating cart');

    if (_cartDataSource == null) {
      _logDebug('Cannot validate without API connection');
      return null;
    }

    try {
      final validation = await _cartDataSource.validateCart();
      _logDebug('Cart validation: ${validation.isValid ? "valid" : "invalid"}');

      if (!validation.isValid) {
        emit(state.copyWith(error: validation.errors.join('\n')));
      }

      return validation;
    } catch (e) {
      _logDebug('Error validating cart: $e');
      emit(state.copyWith(error: 'Failed to validate cart: $e'));
      return null;
    }
  }
}
