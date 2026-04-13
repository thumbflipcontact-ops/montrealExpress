import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../model/order.dart';
import '../../../../model/order_api.dart';
import '../../../../model/delivery_time_slot.dart';
import '../../../../core/storage/storage_service_factory.dart';
import '../../data/data_sources/orders_remote_data_source.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(const OrdersState());

  final _remoteDataSource = OrdersRemoteDataSource();

  // Load orders from backend, fall back to local storage
  Future<void> loadOrders({String? userId}) async {
    emit(const OrdersState(isLoading: true));

    try {
      await _remoteDataSource.initialize();
      final response = await _remoteDataSource.getUserOrders(limit: 50);

      final orders = response.items.map(_apiOrderToLocal).toList();
      emit(OrdersState(isLoading: false, orders: orders));
    } catch (_) {
      // Fall back to local storage
      try {
        final storageService = StorageServiceFactory.orders;
        List<Order> orders = await storageService.getAll();
        if (userId != null) {
          orders = orders.where((order) => order.userId == userId).toList();
        }
        emit(OrdersState(isLoading: false, orders: orders));
      } catch (e) {
        emit(OrdersState(isLoading: false, error: e.toString()));
      }
    }
  }

  // Get specific order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final storageService = StorageServiceFactory.orders;
      final order = await storageService.getById(orderId);
      if (order != null) return order;

      try {
        return state.orders.firstWhere((order) => order.id == orderId);
      } catch (_) {
        return null;
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return null;
    }
  }

  // Create order via backend
  Future<void> createOrder({
    required AddressDto shippingAddress,
    required PaymentMethodType paymentMethod,
    String? notes,
    String? phoneNumber,
    // Legacy params kept for compatibility (ignored when backend succeeds)
    List<OrderItem>? items,
    String? deliveryAddress,
    String? paymentId,
    String? userId,
  }) async {
    emit(state.copyWith(isCreating: true, error: null));

    try {
      await _remoteDataSource.initialize();
      final apiOrder = await _remoteDataSource.createOrder(
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        notes: notes,
        phoneNumber: phoneNumber,
      );

      final order = _apiOrderToLocal(apiOrder);

      // Save to local storage for offline access
      try {
        final storageService = StorageServiceFactory.orders;
        await storageService.save(order.copyWith(isSynced: true));
      } catch (_) {}

      final updatedOrders = [order, ...state.orders];
      emit(state.copyWith(
        isCreating: false,
        orders: updatedOrders,
        lastCreatedOrder: order,
      ));
    } catch (e) {
      emit(state.copyWith(isCreating: false, error: e.toString()));
      rethrow;
    }
  }

  // Cancel order via backend
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
    String? additionalDetails,
  }) async {
    emit(state.copyWith(isCancelling: true, error: null));

    try {
      await _remoteDataSource.initialize();
      final apiOrder = await _remoteDataSource.cancelOrder(orderId);
      final cancelledOrder = _apiOrderToLocal(apiOrder);

      // Update local storage
      try {
        final storageService = StorageServiceFactory.orders;
        await storageService.update(cancelledOrder.copyWith(isSynced: true));
      } catch (_) {}

      final updatedOrders = state.orders.map((order) {
        return order.id == orderId ? cancelledOrder : order;
      }).toList();

      emit(state.copyWith(isCancelling: false, orders: updatedOrders));
    } catch (e) {
      // Fall back: cancel locally
      try {
        final storageService = StorageServiceFactory.orders;
        final existing = await storageService.getById(orderId);
        if (existing != null) {
          final updated = existing.copyWith(
            status: OrderStatus.cancelled,
            notes: 'Annulé: $reason${additionalDetails != null ? ' - $additionalDetails' : ''}',
            isSynced: false,
          );
          await storageService.update(updated);
          final updatedOrders = state.orders.map((o) {
            return o.id == orderId ? updated : o;
          }).toList();
          emit(state.copyWith(isCancelling: false, orders: updatedOrders));
        } else {
          emit(state.copyWith(isCancelling: false, error: e.toString()));
        }
      } catch (_) {
        emit(state.copyWith(isCancelling: false, error: e.toString()));
      }
    }
  }

  // Track order by tracking number
  Future<Order?> trackOrder(String trackingNumber) async {
    emit(state.copyWith(isTracking: true, error: null));

    try {
      final order = state.orders.firstWhere(
        (order) => order.trackingNumber == trackingNumber,
      );
      emit(state.copyWith(isTracking: false, trackedOrder: order));
      return order;
    } catch (e) {
      emit(state.copyWith(isTracking: false, error: 'Numéro de suivi non trouvé'));
      return null;
    }
  }

  // Generate invoice/receipt
  Future<void> generateInvoice(String orderId) async {
    emit(state.copyWith(isGeneratingInvoice: true, error: null));

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      final invoicePath = '/storage/invoices/INV_$orderId.pdf';
      emit(state.copyWith(
        isGeneratingInvoice: false,
        lastGeneratedInvoicePath: invoicePath,
      ));
    } catch (e) {
      emit(state.copyWith(isGeneratingInvoice: false, error: e.toString()));
    }
  }

  Future<void> requestRefund({
    required String orderId,
    required String reason,
    required String additionalDetails,
    required double refundAmount,
  }) async {
    emit(state.copyWith(isLoadingDetails: true, error: null));

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final order = state.orders.firstWhere((order) => order.id == orderId);
      final updatedOrder = order.copyWith(status: OrderStatus.refundRequested);
      final updatedOrders = state.orders.map((o) {
        return o.id == orderId ? updatedOrder : o;
      }).toList();
      emit(state.copyWith(isLoadingDetails: false, orders: updatedOrders));
    } catch (e) {
      emit(state.copyWith(isLoadingDetails: false, error: e.toString()));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
  void clearTrackedOrder() => emit(state.copyWith(trackedOrder: null));
  void clearLastCreatedOrder() => emit(state.copyWith(lastCreatedOrder: null));

  List<Order> getOrdersByStatus(OrderStatus status) {
    return state.orders.where((order) => order.status == status).toList();
  }

  List<Order> getActiveOrders() {
    return state.orders.where((order) {
      return order.status != OrderStatus.delivered &&
          order.status != OrderStatus.cancelled;
    }).toList();
  }

  Future<List<DeliveryTimeSlot>> getAvailableDeliveryTimeSlots(DateTime date) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return generateTimeSlotsForDate(date);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return [];
    }
  }

  void filterByStatus(OrderStatus? status) {
    if (status == null) {
      emit(state.copyWith(filterStatus: null));
      return;
    }
    emit(state.copyWith(filterStatus: status));
  }

  void clearFilter() => emit(state.copyWith(filterStatus: null));

  // Convert API order to local Order model
  Order _apiOrderToLocal(OrderApi apiOrder) {
    final items = apiOrder.items.map((item) {
      return OrderItem(
        id: item.id,
        product: item.product,
        quantity: item.quantity,
        price: item.price,
      );
    }).toList();

    OrderStatus localStatus;
    switch (apiOrder.status) {
      case OrderStatusApi.pending:
        localStatus = OrderStatus.pending;
        break;
      case OrderStatusApi.confirmed:
        localStatus = OrderStatus.confirmed;
        break;
      case OrderStatusApi.processing:
        localStatus = OrderStatus.processing;
        break;
      case OrderStatusApi.preparing:
      case OrderStatusApi.readyForDelivery:
        localStatus = OrderStatus.confirmed;
        break;
      case OrderStatusApi.outForDelivery:
      case OrderStatusApi.shipped:
        localStatus = OrderStatus.shipped;
        break;
      case OrderStatusApi.delivered:
        localStatus = OrderStatus.delivered;
        break;
      case OrderStatusApi.cancelled:
        localStatus = OrderStatus.cancelled;
        break;
      case OrderStatusApi.refundRequested:
        localStatus = OrderStatus.refundRequested;
        break;
      case OrderStatusApi.refunded:
        localStatus = OrderStatus.delivered;
        break;
    }

    return Order(
      id: apiOrder.id,
      userId: apiOrder.userId,
      orderItems: items,
      status: localStatus,
      subtotal: apiOrder.subtotal,
      shipping: apiOrder.shipping,
      total: apiOrder.total,
      trackingNumber: apiOrder.trackingNumber,
      notes: apiOrder.notes,
      createdAt: apiOrder.createdAt,
      isSynced: true,
    );
  }
}
