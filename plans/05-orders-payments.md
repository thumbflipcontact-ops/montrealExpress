# Phase 5: Orders & Payments

> Week 5: Order creation, tracking, and payment processing

## Goals

- [ ] Create order DTOs
- [ ] Implement order remote data source
- [ ] Create order repository with offline support
- [ ] Update OrdersCubit
- [ ] Create payment DTOs
- [ ] Implement payment processing
- [ ] Add receipt upload functionality

## Estimated Time: 4-5 days

---

## Part 1: Order Management

### Backend API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/orders` | List user orders |
| GET | `/orders/:id` | Order details |
| POST | `/orders` | Create order |
| PATCH | `/orders/:id/cancel` | Cancel order |
| POST | `/orders/:id/refund` | Request refund |

### Step 1: Create Order DTOs

**File:** `lib/features/orders/data/models/order_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../../products/data/models/product_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final String id;
  @JsonKey(name: 'order_number')
  final String orderNumber;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'shipping_address_id')
  final String shippingAddressId;
  @JsonKey(name: 'shipping_address')
  final ShippingAddressModel? shippingAddress;
  final String status;
  final List<OrderItemModel> items;
  final double subtotal;
  @JsonKey(name: 'shipping_cost')
  final double shippingCost;
  final double tax;
  final double discount;
  final double total;
  final String currency;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @JsonKey(name: 'delivery_method')
  final String? deliveryMethod;
  @JsonKey(name: 'delivery_time_slot')
  final String? deliveryTimeSlot;
  @JsonKey(name: 'tracking_number')
  final String? trackingNumber;
  @JsonKey(name: 'customer_notes')
  final String? customerNotes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'confirmed_at')
  final DateTime? confirmedAt;
  @JsonKey(name: 'shipped_at')
  final DateTime? shippedAt;
  @JsonKey(name: 'delivered_at')
  final DateTime? deliveredAt;
  @JsonKey(name: 'is_synced')
  final bool isSynced;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.shippingAddressId,
    this.shippingAddress,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.discount,
    required this.total,
    this.currency = 'XOF',
    required this.paymentMethod,
    required this.paymentStatus,
    this.deliveryMethod,
    this.deliveryTimeSlot,
    this.trackingNumber,
    this.customerNotes,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.isSynced = true,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  bool get canCancel => 
      status == 'pending' || status == 'confirmed';
  
  bool get canRequestRefund => 
      status == 'delivered';
  
  bool get isDelivered => status == 'delivered';
  
  bool get isCancelled => status == 'cancelled';
}

@JsonSerializable()
class OrderItemModel {
  final String id;
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'product_id')
  final String productId;
  final ProductModel? product;
  @JsonKey(name: 'product_name')
  final String productName;
  @JsonKey(name: 'product_image')
  final String? productImage;
  final int quantity;
  final double price;
  final double total;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    this.product,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.total,
    required this.createdAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);
}

@JsonSerializable()
class ShippingAddressModel {
  final String id;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String country;
  @JsonKey(name: 'postal_code')
  final String? postalCode;

  ShippingAddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    this.postalCode,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingAddressModelToJson(this);
}
```

### Step 2: Create Order Request DTOs

**File:** `lib/features/orders/data/models/create_order_request.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'create_order_request.g.dart';

@JsonSerializable()
class CreateOrderRequest {
  @JsonKey(name: 'shipping_address_id')
  final String shippingAddressId;
  @JsonKey(name: 'delivery_method')
  final String? deliveryMethod;
  @JsonKey(name: 'delivery_time_slot')
  final String? deliveryTimeSlot;
  @JsonKey(name: 'payment_method_id')
  final String paymentMethodId;
  @JsonKey(name: 'customer_notes')
  final String? customerNotes;
  final List<CreateOrderItemRequest> items;

  CreateOrderRequest({
    required this.shippingAddressId,
    this.deliveryMethod,
    this.deliveryTimeSlot,
    required this.paymentMethodId,
    this.customerNotes,
    required this.items,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

@JsonSerializable()
class CreateOrderItemRequest {
  @JsonKey(name: 'product_id')
  final String productId;
  final int quantity;

  CreateOrderItemRequest({
    required this.productId,
    required this.quantity,
  });

  factory CreateOrderItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderItemRequestToJson(this);
}

@JsonSerializable()
class CancelOrderRequest {
  final String reason;
  @JsonKey(name: 'additional_details')
  final String? additionalDetails;

  CancelOrderRequest({
    required this.reason,
    this.additionalDetails,
  });

  factory CancelOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelOrderRequestToJson(this);
}

@JsonSerializable()
class RefundRequest {
  final String reason;
  @JsonKey(name: 'additional_details')
  final String? additionalDetails;
  @JsonKey(name: 'refund_amount')
  final double refundAmount;

  RefundRequest({
    required this.reason,
    this.additionalDetails,
    required this.refundAmount,
  });

  factory RefundRequest.fromJson(Map<String, dynamic> json) =>
      _$RefundRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefundRequestToJson(this);
}
```

### Step 3: Create Order Remote Data Source

**File:** `lib/features/orders/data/datasources/order_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/api/pagination.dart';
import '../models/order_model.dart';
import '../models/create_order_request.dart';

part 'order_remote_datasource.g.dart';

@RestApi()
abstract class OrderRemoteDataSource {
  factory OrderRemoteDataSource(Dio dio) = _OrderRemoteDataSource;

  @GET('/orders')
  Future<ApiResponse<PaginatedResponse<OrderModel>>> getOrders();

  @GET('/orders/{id}')
  Future<ApiResponse<OrderModel>> getOrderById(@Path('id') String id);

  @POST('/orders')
  Future<ApiResponse<OrderModel>> createOrder(
    @Body() CreateOrderRequest request,
  );

  @PATCH('/orders/{id}/cancel')
  Future<ApiResponse<OrderModel>> cancelOrder(
    @Path('id') String id,
    @Body() CancelOrderRequest request,
  );

  @POST('/orders/{id}/refund')
  Future<ApiResponse<OrderModel>> requestRefund(
    @Path('id') String id,
    @Body() RefundRequest request,
  );

  @GET('/orders/track/{trackingNumber}')
  Future<ApiResponse<OrderModel>> trackOrder(
    @Path('trackingNumber') String trackingNumber,
  );
}
```

### Step 4: Create Order Repository

**File:** `lib/features/orders/data/repositories/order_repository_impl.dart`

```dart
import '../../../../core/api/api_response.dart';
import '../../../../core/api/pagination.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../datasources/order_local_datasource.dart';
import '../models/order_model.dart';
import '../models/create_order_request.dart';

class OrderRepositoryImpl extends BaseRepository implements OrderRepository {
  final OrderRemoteDataSource _remote;
  final OrderLocalDataSource _local;

  OrderRepositoryImpl({
    required OrderRemoteDataSource remote,
    required OrderLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<List<OrderModel>> getOrders() async {
    return handleRequest(
      request: () async {
        final response = await _remote.getOrders();
        final paginated = parseResponse(response);
        final orders = paginated.items;
        await _local.cacheOrders(orders);
        return orders;
      },
      fallback: await _local.getCachedOrders(),
    );
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    return handleRequest(
      request: () async {
        final response = await _remote.getOrderById(id);
        final order = parseResponse(response);
        await _local.cacheOrder(order);
        return order;
      },
      fallback: await _local.getCachedOrder(id),
    );
  }

  @override
  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    return handleRequest(
      request: () async {
        final response = await _remote.createOrder(request);
        final order = parseResponse(response);
        await _local.cacheOrder(order);
        return order;
      },
    );
  }

  @override
  Future<OrderModel> createOrderOffline(CreateOrderRequest request) async {
    // Create order locally when offline
    final localOrder = OrderModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'PENDING',
      userId: request.shippingAddressId, // Should get from auth
      shippingAddressId: request.shippingAddressId,
      status: 'pending',
      items: [], // Convert from request
      subtotal: 0,
      shippingCost: 1000,
      tax: 0,
      discount: 0,
      total: 0,
      paymentMethod: request.paymentMethodId,
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    
    await _local.cacheOrder(localOrder);
    await _local.queueOrderForSync(localOrder.id, request);
    
    return localOrder;
  }

  @override
  Future<void> syncPendingOrders() async {
    final pendingOrders = await _local.getPendingOrders();
    
    for (final order in pendingOrders) {
      try {
        final request = await _local.getPendingOrderRequest(order.id);
        if (request != null) {
          final syncedOrder = await createOrder(request);
          await _local.markOrderAsSynced(order.id, syncedOrder);
        }
      } catch (e) {
        // Stop processing on error
        break;
      }
    }
  }

  @override
  Future<OrderModel> cancelOrder(
    String id,
    CancelOrderRequest request,
  ) async {
    return handleRequest(
      request: () async {
        final response = await _remote.cancelOrder(id, request);
        final order = parseResponse(response);
        await _local.cacheOrder(order);
        return order;
      },
    );
  }

  @override
  Future<OrderModel> requestRefund(
    String id,
    RefundRequest request,
  ) async {
    return handleRequest(
      request: () async {
        final response = await _remote.requestRefund(id, request);
        final order = parseResponse(response);
        await _local.cacheOrder(order);
        return order;
      },
    );
  }

  @override
  Future<OrderModel?> trackOrder(String trackingNumber) async {
    return handleRequest(
      request: () async {
        final response = await _remote.trackOrder(trackingNumber);
        return parseResponse(response);
      },
    );
  }
}
```

---

## Part 2: Payment Processing

### Backend API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/payments/history` | Payment history |
| POST | `/payments/:orderId` | Submit payment |
| POST | `/payments/:id/upload-receipt` | Upload receipt |
| POST | `/upload/image` | Upload image |

### Step 1: Create Payment DTOs

**File:** `lib/features/payment/data/models/payment_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final String id;
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'user_id')
  final String userId;
  final double amount;
  final String currency;
  @JsonKey(name: 'method_id')
  final String methodId;
  final String status;
  @JsonKey(name: 'receipt_url')
  final String? receiptUrl;
  @JsonKey(name: 'transaction_ref')
  final String? transactionRef;
  final String? description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'verified_at')
  final DateTime? verifiedAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    this.currency = 'XOF',
    required this.methodId,
    required this.status,
    this.receiptUrl,
    this.transactionRef,
    this.description,
    required this.createdAt,
    this.verifiedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}

@JsonSerializable()
class SubmitPaymentRequest {
  @JsonKey(name: 'method_id')
  final String methodId;
  @JsonKey(name: 'transaction_ref')
  final String? transactionRef;
  @JsonKey(name: 'receipt_url')
  final String? receiptUrl;
  final String? description;

  SubmitPaymentRequest({
    required this.methodId,
    this.transactionRef,
    this.receiptUrl,
    this.description,
  });

  factory SubmitPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitPaymentRequestToJson(this);
}

@JsonSerializable()
class UploadReceiptResponse {
  final String url;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  UploadReceiptResponse({
    required this.url,
    this.thumbnailUrl,
  });

  factory UploadReceiptResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadReceiptResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadReceiptResponseToJson(this);
}
```

### Step 2: Create Payment Remote Data Source

**File:** `lib/features/payment/data/datasources/payment_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/api/api_response.dart';
import '../models/payment_model.dart';

part 'payment_remote_datasource.g.dart';

@RestApi()
abstract class PaymentRemoteDataSource {
  factory PaymentRemoteDataSource(Dio dio) = _PaymentRemoteDataSource;

  @GET('/payments/history')
  Future<ApiResponse<List<PaymentModel>>> getPaymentHistory();

  @POST('/payments/{orderId}')
  Future<ApiResponse<PaymentModel>> submitPayment(
    @Path('orderId') String orderId,
    @Body() SubmitPaymentRequest request,
  );

  @POST('/payments/{id}/upload-receipt')
  @MultiPart()
  Future<ApiResponse<UploadReceiptResponse>> uploadReceipt(
    @Path('id') String paymentId,
    @Part(name: 'file') File file,
  );

  @POST('/upload/image')
  @MultiPart()
  Future<ApiResponse<UploadReceiptResponse>> uploadImage(
    @Part(name: 'file') File file,
  );
}
```

### Step 3: Create Payment Repository

**File:** `lib/features/payment/data/repositories/payment_repository_impl.dart`

```dart
import 'dart:io';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl extends BaseRepository implements PaymentRepository {
  final PaymentRemoteDataSource _remote;

  PaymentRepositoryImpl({required PaymentRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<List<PaymentModel>> getPaymentHistory() async {
    return handleRequest(
      request: () async {
        final response = await _remote.getPaymentHistory();
        return parseResponse(response);
      },
    );
  }

  @override
  Future<PaymentModel> submitPayment(
    String orderId,
    SubmitPaymentRequest request,
  ) async {
    return handleRequest(
      request: () async {
        final response = await _remote.submitPayment(orderId, request);
        return parseResponse(response);
      },
    );
  }

  @override
  Future<String> uploadReceipt(String paymentId, File file) async {
    return handleRequest(
      request: () async {
        final response = await _remote.uploadReceipt(paymentId, file);
        final result = parseResponse(response);
        return result.url;
      },
    );
  }

  @override
  Future<String> uploadImage(File file) async {
    return handleRequest(
      request: () async {
        final response = await _remote.uploadImage(file);
        final result = parseResponse(response);
        return result.url;
      },
    );
  }
}
```

---

## Checklist

- [ ] OrderModel and OrderItemModel DTOs created
- [ ] CreateOrderRequest, CancelOrderRequest, RefundRequest DTOs created
- [ ] OrderRemoteDataSource implemented
- [ ] OrderLocalDataSource with offline sync
- [ ] OrderRepositoryImpl with sync logic
- [ ] PaymentModel and SubmitPaymentRequest DTOs created
- [ ] PaymentRemoteDataSource implemented
- [ ] PaymentRepositoryImpl created
- [ ] OrdersCubit updated for API integration
- [ ] PaymentCubit updated for API integration
- [ ] Receipt upload functionality implemented
- [ ] Offline order creation handling
- [ ] Tests written

---

## Next Phase

➡️ [Phase 6: Advanced Features](./06-advanced-features.md)
