import 'package:hive/hive.dart';
import 'package:abdoul_express/model/product.dart';
import 'delivery_address.dart';
import 'delivery_method.dart';

part 'order.g.dart';

@HiveType(typeId: 0)
enum OrderStatus {
  @HiveField(0)
  pending('En attente'),
  @HiveField(1)
  confirmed('Confirmée'),
  @HiveField(2)
  processing('En traitement'),
  @HiveField(3)
  preparing('En préparation'),
  @HiveField(4)
  readyForDelivery('Prête pour livraison'),
  @HiveField(5)
  outForDelivery('En livraison'),
  @HiveField(6)
  shipped('Expédiée'),
  @HiveField(7)
  delivered('Livrée'),
  @HiveField(8)
  cancelled('Annulée'),
  @HiveField(9)
  refundRequested('Remboursement demandé'),
  @HiveField(10)
  refunded('Remboursée');

  const OrderStatus(this.displayName);
  final String displayName;
}

// Order item model
@HiveType(typeId: 1)
class OrderItem extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final Product product;
  @HiveField(2)
  final int quantity;
  @HiveField(3)
  final double price;

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;

  String get productTitle => product.title;
  double get totalPrice => total;

  String? get productImage => product.imageAsset ?? product.imageUrl;
}

// Order model
@HiveType(typeId: 2)
class   Order extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  HiveList? items;
  @HiveField(3)
  final OrderStatus status;
  @HiveField(4)
  final double subtotal;
  @HiveField(5)
  final double shipping;
  @HiveField(6)
  final double total;
  @HiveField(7)
  final String? deliveryAddressId;
  @HiveField(8)
  final String? deliveryAddress;
  @HiveField(9)
  final DeliveryAddress? deliveryAddressObj;
  @HiveField(10)
  final DeliveryMethod? deliveryMethod;
  @HiveField(11)
  final String? paymentId;
  @HiveField(12)
  final String? trackingNumber;
  @HiveField(13)
  final DateTime createdAt;
  @HiveField(14)
  final DateTime? confirmedAt;
  @HiveField(15)
  final DateTime? shippedAt;
  @HiveField(16)
  final DateTime? deliveredAt;
  @HiveField(17)
  final String? notes;
  @HiveField(18)
  final bool isSynced;

  Order({
    required this.id,
    required this.userId,
    required List<OrderItem> orderItems,
    required this.status,
    required this.subtotal,
    required this.shipping,
    required this.total,
    this.deliveryAddressId,
    this.deliveryAddress,
    this.deliveryAddressObj,
    this.deliveryMethod,
    this.paymentId,
    this.trackingNumber,
    required this.createdAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.notes,
    this.isSynced = false,
  }) : items = null;

  // Getter for items list
  List<OrderItem> get orderItems => items?.cast<OrderItem>().toList() ?? [];

  // Computed properties for compatibility
  double get deliveryFee => shipping;
  double get taxAmount => total - subtotal - shipping; // Simplified
  double get discountAmount => 0.0; // Simplified
  double get totalAmount => total;

  String? get paymentMethod => paymentId;

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? orderItems,
    OrderStatus? status,
    double? subtotal,
    double? shipping,
    double? total,
    String? deliveryAddressId,
    String? deliveryAddress,
    DeliveryAddress? deliveryAddressObj,
    DeliveryMethod? deliveryMethod,
    String? paymentId,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    String? notes,
    bool? isSynced,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderItems: orderItems ?? this.orderItems,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryAddressObj: deliveryAddressObj ?? this.deliveryAddressObj,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      paymentId: paymentId ?? this.paymentId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
