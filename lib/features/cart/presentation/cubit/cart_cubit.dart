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

  Future<void> _initialize() async {
    final dataSource = _cartDataSource;
    final controller = _controller;

    if (dataSource != null) {
      await loadCart();
    } else if (controller != null) {
      _syncFromController();
    }
  }

  Future<void> loadCart() async {
    final dataSource = _cartDataSource;
    final controller = _controller;

    if (dataSource == null) {
      if (controller != null) _syncFromController();
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      await dataSource.initialize();
      final cart = await dataSource.getCart();
      _currentCart = cart;

      final cartItems = cart.items.map((e) {
        return CartItem(product: e.product, quantity: e.quantity);
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
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: '$e'));

      if (controller != null) {
        _syncFromController();
      }
    }
  }

  void _syncFromController() {
    final controller = _controller;
    if (controller == null) return;

    final items = controller.cartItems.map((e) {
      return CartItem(product: e.product, quantity: e.quantity);
    }).toList();

    emit(CartState(
      items: items,
      subtotal: controller.subtotal,
      total: controller.subtotal,
    ));
  }

  Future<void> addToCart(CartItem item) async {
    final dataSource = _cartDataSource;
    final controller = _controller;

    if (dataSource != null) {
      emit(state.copyWith(isLoading: true));

      try {
        await dataSource.initialize();
        final cart = await dataSource.addToCart(
          productId: item.product.id,
          quantity: item.quantity,
        );

        _currentCart = cart;

        final cartItems = cart.items.map((e) {
          return CartItem(product: e.product, quantity: e.quantity);
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
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: '$e'));
      }
    } else if (controller != null) {
      controller.addToCart(item.product, quantity: item.quantity);
      _syncFromController();
    }
  }

  Future<void> removeFromCart(String productId) async {
    final dataSource = _cartDataSource;
    final controller = _controller;

    if (dataSource != null && _currentCart != null) {
      final cartItem = _currentCart!.items.firstWhere(
        (e) => e.product.id == productId,
        orElse: () => _currentCart!.items.first,
      );

      emit(state.copyWith(isLoading: true));

      try {
        final cart = await dataSource.removeCartItem(cartItem.id);
        _currentCart = cart;

        final cartItems = cart.items.map((e) {
          return CartItem(product: e.product, quantity: e.quantity);
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
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: '$e'));
      }
    } else if (controller != null) {
      controller.removeFromCart(productId);
      _syncFromController();
    }
  }

  Future<void> setQuantity(String productId, int quantity) async {
    final dataSource = _cartDataSource;
    final controller = _controller;

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    if (dataSource != null && _currentCart != null) {
      final cartItem = _currentCart!.items.firstWhere(
        (e) => e.product.id == productId,
        orElse: () => _currentCart!.items.first,
      );

      emit(state.copyWith(isLoading: true));

      try {
        final cart = await dataSource.updateCartItem(
          itemId: cartItem.id,
          quantity: quantity,
        );

        _currentCart = cart;

        final cartItems = cart.items.map((e) {
          return CartItem(product: e.product, quantity: e.quantity);
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
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: '$e'));
      }
    } else if (controller != null) {
      controller.setQuantity(productId, quantity);
      _syncFromController();
    }
  }

  Future<void> clearCart() async {
    final dataSource = _cartDataSource;
    final controller = _controller;

    if (dataSource != null) {
      emit(state.copyWith(isLoading: true));

      try {
        await dataSource.clearCart();
        _currentCart = null;
        emit(CartState.initial());
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: '$e'));
      }
    } else if (controller != null) {
      for (final item in controller.cartItems) {
        controller.removeFromCart(item.product.id);
      }
      _syncFromController();
    }
  }
}