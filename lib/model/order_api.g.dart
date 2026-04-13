// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderApi _$OrderApiFromJson(Map<String, dynamic> json) => OrderApi(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemApi.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$OrderStatusApiEnumMap, json['status']),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'] == null
          ? null
          : DeliveryAddress.fromJson(
              json['deliveryAddress'] as Map<String, dynamic>),
      paymentMethod: $enumDecodeNullable(
          _$PaymentMethodTypeEnumMap, json['paymentMethod']),
      paymentId: json['paymentId'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      notes: json['notes'] as String?,
      statusHistory: (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      shippedAt: json['shippedAt'] == null
          ? null
          : DateTime.parse(json['shippedAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
    );

Map<String, dynamic> _$OrderApiToJson(OrderApi instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'items': instance.items,
      'status': _$OrderStatusApiEnumMap[instance.status]!,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'discount': instance.discount,
      'shipping': instance.shipping,
      'total': instance.total,
      'deliveryAddress': instance.deliveryAddress,
      'paymentMethod': _$PaymentMethodTypeEnumMap[instance.paymentMethod],
      'paymentId': instance.paymentId,
      'trackingNumber': instance.trackingNumber,
      'notes': instance.notes,
      'statusHistory': instance.statusHistory,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'shippedAt': instance.shippedAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
    };

const _$OrderStatusApiEnumMap = {
  OrderStatusApi.pending: 'pending',
  OrderStatusApi.confirmed: 'confirmed',
  OrderStatusApi.processing: 'processing',
  OrderStatusApi.preparing: 'preparing',
  OrderStatusApi.readyForDelivery: 'ready_for_delivery',
  OrderStatusApi.outForDelivery: 'out_for_delivery',
  OrderStatusApi.shipped: 'shipped',
  OrderStatusApi.delivered: 'delivered',
  OrderStatusApi.cancelled: 'cancelled',
  OrderStatusApi.refundRequested: 'refund_requested',
  OrderStatusApi.refunded: 'refunded',
};

const _$PaymentMethodTypeEnumMap = {
  PaymentMethodType.wave: 'WAVE',
  PaymentMethodType.orangeMoney: 'ORANGE_MONEY',
  PaymentMethodType.moovMoney: 'MOOV_MONEY',
  PaymentMethodType.cashOnDelivery: 'CASH_ON_DELIVERY',
  PaymentMethodType.bankTransfer: 'BANK_TRANSFER',
  PaymentMethodType.manualReceipt: 'MANUAL_RECEIPT',
};

OrderItemApi _$OrderItemApiFromJson(Map<String, dynamic> json) => OrderItemApi(
      id: json['id'] as String,
      productId: json['productId'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$OrderItemApiToJson(OrderItemApi instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'product': instance.product,
      'quantity': instance.quantity,
      'price': instance.price,
      'subtotal': instance.subtotal,
      'createdAt': instance.createdAt.toIso8601String(),
    };

OrderStatusHistory _$OrderStatusHistoryFromJson(Map<String, dynamic> json) =>
    OrderStatusHistory(
      status: $enumDecode(_$OrderStatusApiEnumMap, json['status']),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$OrderStatusHistoryToJson(OrderStatusHistory instance) =>
    <String, dynamic>{
      'status': _$OrderStatusApiEnumMap[instance.status]!,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

AddressDto _$AddressDtoFromJson(Map<String, dynamic> json) => AddressDto(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      region: json['region'] as String,
      country: json['country'] as String,
      postalCode: json['postalCode'] as String?,
    );

Map<String, dynamic> _$AddressDtoToJson(AddressDto instance) {
  final val = <String, dynamic>{
    'fullName': instance.fullName,
    'phone': instance.phone,
    'street': instance.street,
    'city': instance.city,
    'region': instance.region,
    'country': instance.country,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('postalCode', instance.postalCode);
  return val;
}

CreateOrderRequest _$CreateOrderRequestFromJson(Map<String, dynamic> json) =>
    CreateOrderRequest(
      shippingAddress:
          AddressDto.fromJson(json['shippingAddress'] as Map<String, dynamic>),
      billingAddress: json['billingAddress'] == null
          ? null
          : AddressDto.fromJson(json['billingAddress'] as Map<String, dynamic>),
      paymentMethod:
          $enumDecode(_$PaymentMethodTypeEnumMap, json['paymentMethod']),
      notes: json['notes'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );

Map<String, dynamic> _$CreateOrderRequestToJson(CreateOrderRequest instance) {
  final val = <String, dynamic>{
    'shippingAddress': instance.shippingAddress,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('billingAddress', instance.billingAddress);
  val['paymentMethod'] = _$PaymentMethodTypeEnumMap[instance.paymentMethod]!;
  writeNotNull('notes', instance.notes);
  writeNotNull('phoneNumber', instance.phoneNumber);
  return val;
}

OrderTracking _$OrderTrackingFromJson(Map<String, dynamic> json) =>
    OrderTracking(
      trackingNumber: json['trackingNumber'] as String,
      status: $enumDecode(_$OrderStatusApiEnumMap, json['status']),
      statusHistory: (json['statusHistory'] as List<dynamic>)
          .map((e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      estimatedDelivery: DateTime.parse(json['estimatedDelivery'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$OrderTrackingToJson(OrderTracking instance) =>
    <String, dynamic>{
      'trackingNumber': instance.trackingNumber,
      'status': _$OrderStatusApiEnumMap[instance.status]!,
      'statusHistory': instance.statusHistory,
      'estimatedDelivery': instance.estimatedDelivery.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

OrderListResponse _$OrderListResponseFromJson(Map<String, dynamic> json) =>
    OrderListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderApi.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$OrderListResponseToJson(OrderListResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
    };
