import 'package:json_annotation/json_annotation.dart';
import 'product.dart';
import 'delivery_address.dart';

part 'order_api.g.dart';

/// Order status enum matching backend
enum OrderStatusApi {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('processing')
  processing,
  @JsonValue('preparing')
  preparing,
  @JsonValue('ready_for_delivery')
  readyForDelivery,
  @JsonValue('out_for_delivery')
  outForDelivery,
  @JsonValue('shipped')
  shipped,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('refund_requested')
  refundRequested,
  @JsonValue('refunded')
  refunded;

  String get displayName {
    switch (this) {
      case OrderStatusApi.pending:
        return 'En attente';
      case OrderStatusApi.confirmed:
        return 'Confirmée';
      case OrderStatusApi.processing:
        return 'En traitement';
      case OrderStatusApi.preparing:
        return 'En préparation';
      case OrderStatusApi.readyForDelivery:
        return 'Prête pour livraison';
      case OrderStatusApi.outForDelivery:
        return 'En livraison';
      case OrderStatusApi.shipped:
        return 'Expédiée';
      case OrderStatusApi.delivered:
        return 'Livrée';
      case OrderStatusApi.cancelled:
        return 'Annulée';
      case OrderStatusApi.refundRequested:
        return 'Remboursement demandé';
      case OrderStatusApi.refunded:
        return 'Remboursée';
    }
  }
}

/// Payment method enum — values match backend Prisma enum (uppercase)
enum PaymentMethodType {
  @JsonValue('WAVE')
  wave,
  @JsonValue('ORANGE_MONEY')
  orangeMoney,
  @JsonValue('MOOV_MONEY')
  moovMoney,
  @JsonValue('CASH_ON_DELIVERY')
  cashOnDelivery,
  @JsonValue('BANK_TRANSFER')
  bankTransfer,
  @JsonValue('MANUAL_RECEIPT')
  manualReceipt;

  String get displayName {
    switch (this) {
      case PaymentMethodType.wave:
        return 'Wave';
      case PaymentMethodType.orangeMoney:
        return 'Orange Money';
      case PaymentMethodType.moovMoney:
        return 'Moov Money';
      case PaymentMethodType.cashOnDelivery:
        return 'Paiement à la livraison';
      case PaymentMethodType.bankTransfer:
        return 'Virement bancaire';
      case PaymentMethodType.manualReceipt:
        return 'Reçu manuel';
    }
  }

  /// Map from UI method ID string to enum value
  static PaymentMethodType fromMethodId(String methodId) {
    switch (methodId) {
      case 'wave':
        return PaymentMethodType.wave;
      case 'orange_money':
        return PaymentMethodType.orangeMoney;
      case 'moov_money':
        return PaymentMethodType.moovMoney;
      case 'cash_on_delivery':
        return PaymentMethodType.cashOnDelivery;
      case 'bank_transfer':
        return PaymentMethodType.bankTransfer;
      case 'manual_receipt':
        return PaymentMethodType.manualReceipt;
      default:
        return PaymentMethodType.cashOnDelivery;
    }
  }
}

/// Order from API
@JsonSerializable()
class OrderApi {
  final String id;
  final String userId;
  final List<OrderItemApi> items;
  final OrderStatusApi status;
  final double subtotal;
  final double tax;
  final double discount;
  final double shipping;
  final double total;
  final DeliveryAddress? deliveryAddress;
  final PaymentMethodType? paymentMethod;
  final String? paymentId;
  final String? trackingNumber;
  final String? notes;
  final List<OrderStatusHistory>? statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  OrderApi({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.shipping,
    required this.total,
    this.deliveryAddress,
    this.paymentMethod,
    this.paymentId,
    this.trackingNumber,
    this.notes,
    this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
  });

  factory OrderApi.fromJson(Map<String, dynamic> json) =>
      _$OrderApiFromJson(json);

  Map<String, dynamic> toJson() => _$OrderApiToJson(this);

  /// Get total number of items
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if order can be cancelled
  bool get canBeCancelled =>
      status == OrderStatusApi.pending ||
      status == OrderStatusApi.confirmed ||
      status == OrderStatusApi.processing;

  /// Check if order is completed
  bool get isCompleted =>
      status == OrderStatusApi.delivered || status == OrderStatusApi.refunded;

  /// Check if order is in progress
  bool get isInProgress =>
      status != OrderStatusApi.cancelled &&
      status != OrderStatusApi.delivered &&
      status != OrderStatusApi.refunded;
}

/// Order item from API
@JsonSerializable()
class OrderItemApi {
  final String id;
  final String productId;
  final Product product;
  final int quantity;
  final double price;
  final double subtotal;
  final DateTime createdAt;

  OrderItemApi({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.createdAt,
  });

  factory OrderItemApi.fromJson(Map<String, dynamic> json) =>
      _$OrderItemApiFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemApiToJson(this);

  double get total => price * quantity;
}

/// Order status history entry
@JsonSerializable()
class OrderStatusHistory {
  final OrderStatusApi status;
  final String? notes;
  final DateTime createdAt;

  OrderStatusHistory({
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusHistoryToJson(this);
}

/// Address DTO for order shipping/billing address
/// Matches backend AddressDto: fullName*, phone*, street*, city*, region*, country*, postalCode?
@JsonSerializable(includeIfNull: false)
class AddressDto {
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String region;
  final String country;
  final String? postalCode;

  AddressDto({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.region,
    required this.country,
    this.postalCode,
  });

  factory AddressDto.fromJson(Map<String, dynamic> json) =>
      _$AddressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddressDtoToJson(this);
}

/// Request to create an order
/// Matches backend CreateOrderDto: shippingAddress*, billingAddress?, paymentMethod*, notes?, phoneNumber?
@JsonSerializable(includeIfNull: false)
class CreateOrderRequest {
  final AddressDto shippingAddress;
  final AddressDto? billingAddress;
  final PaymentMethodType paymentMethod;
  final String? notes;
  final String? phoneNumber;

  CreateOrderRequest({
    required this.shippingAddress,
    this.billingAddress,
    required this.paymentMethod,
    this.notes,
    this.phoneNumber,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

/// Order tracking response (for public tracking)
@JsonSerializable()
class OrderTracking {
  final String trackingNumber;
  final OrderStatusApi status;
  final List<OrderStatusHistory> statusHistory;
  final DateTime estimatedDelivery;
  final DateTime createdAt;

  OrderTracking({
    required this.trackingNumber,
    required this.status,
    required this.statusHistory,
    required this.estimatedDelivery,
    required this.createdAt,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTrackingToJson(this);
}

/// Order list response with pagination
@JsonSerializable()
class OrderListResponse {
  final List<OrderApi> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  OrderListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderListResponseToJson(this);

  bool get hasMore => page < totalPages;
}
