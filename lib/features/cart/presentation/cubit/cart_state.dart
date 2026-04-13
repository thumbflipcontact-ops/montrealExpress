part of 'cart_cubit.dart';

class CartState extends Equatable {
  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.discount = 0.0,
    this.total = 0.0,
    this.couponCode,
  });

  const CartState.initial()
      : this(
          items: const [],
          isLoading: false,
          error: null,
          subtotal: 0.0,
          tax: 0.0,
          discount: 0.0,
          total: 0.0,
        );

  final List<CartItem> items;
  final bool isLoading;
  final String? error;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String? couponCode;

  /// Get total number of items in cart
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has error
  bool get hasError => error != null && error!.isNotEmpty;

  /// Check if coupon is applied
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    String? couponCode,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      couponCode: couponCode ?? this.couponCode,
    );
  }

  @override
  List<Object?> get props => [
        items.length,
        isLoading,
        error,
        subtotal,
        tax,
        discount,
        total,
        couponCode,
        // Include each item's product ID and quantity to detect changes
        ...items.map((item) => '${item.product.id}:${item.quantity}'),
      ];
}
