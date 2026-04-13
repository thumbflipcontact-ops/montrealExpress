part of 'orders_cubit.dart';

class OrdersState extends Equatable {
  const OrdersState({
    this.orders = const [],
    this.trackedOrder,
    this.lastCreatedOrder,
    this.lastGeneratedInvoicePath,
    this.isLoading = false,
    this.isCreating = false,
    this.isCancelling = false,
    this.isTracking = false,
    this.isGeneratingInvoice = false,
    this.error,
    this.filterStatus,
    this.isLoadingDetails = false,
  });

  final List<Order> orders;
  final Order? trackedOrder;
  final Order? lastCreatedOrder;
  final String? lastGeneratedInvoicePath;
  final bool isLoading;
  final bool isCreating;
  final bool isCancelling;
  final bool isTracking;
  final bool isGeneratingInvoice;
  final String? error;
  final OrderStatus? filterStatus;
  final bool isLoadingDetails;

  List<Order> get filteredOrders {
    if (filterStatus == null) return orders;
    return orders.where((order) => order.status == filterStatus).toList();
  }

  OrdersState copyWith({
    List<Order>? orders,
    Order? trackedOrder,
    Order? lastCreatedOrder,
    String? lastGeneratedInvoicePath,
    bool? isLoading,
    bool? isCreating,
    bool? isCancelling,
    bool? isTracking,
    bool? isGeneratingInvoice,
    String? error,
    OrderStatus? filterStatus,
    bool? isLoadingDetails,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      trackedOrder: trackedOrder,
      lastCreatedOrder: lastCreatedOrder,
      lastGeneratedInvoicePath: lastGeneratedInvoicePath,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isCancelling: isCancelling ?? this.isCancelling,
      isTracking: isTracking ?? this.isTracking,
      isGeneratingInvoice: isGeneratingInvoice ?? this.isGeneratingInvoice,
      error: error,
      filterStatus: filterStatus ?? this.filterStatus,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        trackedOrder,
        lastCreatedOrder,
        lastGeneratedInvoicePath,
        isLoading,
        isCreating,
        isCancelling,
        isTracking,
        isGeneratingInvoice,
        error,
        filterStatus,
        isLoadingDetails,
      ];
}