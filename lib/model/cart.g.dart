// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cart _$CartFromJson(Map<String, dynamic> json) => Cart(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      sessionId: json['sessionId'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      couponCode: json['couponCode'] as String?,
      couponDiscount: (json['couponDiscount'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CartToJson(Cart instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'sessionId': instance.sessionId,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'discount': instance.discount,
      'total': instance.total,
      'couponCode': instance.couponCode,
      'couponDiscount': instance.couponDiscount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    CartItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CartItemModelToJson(CartItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'product': instance.product,
      'quantity': instance.quantity,
      'price': instance.price,
      'subtotal': instance.subtotal,
      'createdAt': instance.createdAt.toIso8601String(),
    };

AddToCartRequest _$AddToCartRequestFromJson(Map<String, dynamic> json) =>
    AddToCartRequest(
      productId: json['productId'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$AddToCartRequestToJson(AddToCartRequest instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'quantity': instance.quantity,
    };

UpdateCartItemRequest _$UpdateCartItemRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateCartItemRequest(
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$UpdateCartItemRequestToJson(
        UpdateCartItemRequest instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
    };

ApplyCouponRequest _$ApplyCouponRequestFromJson(Map<String, dynamic> json) =>
    ApplyCouponRequest(
      couponCode: json['couponCode'] as String,
    );

Map<String, dynamic> _$ApplyCouponRequestToJson(ApplyCouponRequest instance) =>
    <String, dynamic>{
      'couponCode': instance.couponCode,
    };

CartValidation _$CartValidationFromJson(Map<String, dynamic> json) =>
    CartValidation(
      isValid: json['isValid'] as bool,
      errors:
          (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
      warnings:
          (json['warnings'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CartValidationToJson(CartValidation instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'errors': instance.errors,
      'warnings': instance.warnings,
    };
