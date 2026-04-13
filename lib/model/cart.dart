import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'cart.g.dart';

/// Cart model matching backend schema
@JsonSerializable()
class Cart {
  final String id;
  final String? userId;
  final String? sessionId;
  final List<CartItemModel> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String? couponCode;
  final double? couponDiscount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    this.userId,
    this.sessionId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    this.couponCode,
    this.couponDiscount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  Map<String, dynamic> toJson() => _$CartToJson(this);

  /// Get total number of items in cart
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has coupon applied
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  Cart copyWith({
    String? id,
    String? userId,
    String? sessionId,
    List<CartItemModel>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    String? couponCode,
    double? couponDiscount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Cart item model from backend
@JsonSerializable()
class CartItemModel {
  final String id;
  final String productId;
  final Product product;
  final int quantity;
  final double price; // Price at time of adding to cart
  final double subtotal;
  final DateTime createdAt;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.createdAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  /// Get total for this item
  double get total => price * quantity;

  CartItemModel copyWith({
    String? id,
    String? productId,
    Product? product,
    int? quantity,
    double? price,
    double? subtotal,
    DateTime? createdAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Request to add item to cart
@JsonSerializable()
class AddToCartRequest {
  final String productId;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    required this.quantity,
  });

  factory AddToCartRequest.fromJson(Map<String, dynamic> json) =>
      _$AddToCartRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddToCartRequestToJson(this);
}

/// Request to update cart item quantity
@JsonSerializable()
class UpdateCartItemRequest {
  final int quantity;

  UpdateCartItemRequest({
    required this.quantity,
  });

  factory UpdateCartItemRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCartItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCartItemRequestToJson(this);
}

/// Request to apply coupon
@JsonSerializable()
class ApplyCouponRequest {
  final String couponCode;

  ApplyCouponRequest({
    required this.couponCode,
  });

  factory ApplyCouponRequest.fromJson(Map<String, dynamic> json) =>
      _$ApplyCouponRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ApplyCouponRequestToJson(this);
}

/// Cart validation response
@JsonSerializable()
class CartValidation {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  CartValidation({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  factory CartValidation.fromJson(Map<String, dynamic> json) =>
      _$CartValidationFromJson(json);

  Map<String, dynamic> toJson() => _$CartValidationToJson(this);

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}
