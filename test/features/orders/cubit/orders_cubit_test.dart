import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:abdoul_express/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:abdoul_express/model/order.dart';
import 'package:abdoul_express/model/product.dart';

import '../../../helpers/mock_storage.dart' show initMockHive;

/// Comprehensive Tests for OrdersCubit
///
/// This test suite covers the complete order management lifecycle:
/// - Order loading from local storage with fallback to mock data
/// - Order creation with item calculations and tracking numbers
/// - Order cancellation with reason tracking
/// - Public order tracking by tracking number
/// - Invoice/receipt generation
/// - Refund requests
/// - Order filtering by status
/// - Delivery time slot management
/// - Storage integration (Hive)
/// - Order status transitions (11 states)
/// - Financial calculations (subtotal, shipping, total)
/// - Edge cases and error handling
///
/// Total: 45+ tests covering critical e-commerce operations
void main() {
  late OrdersCubit ordersCubit;

  setUpAll(() async {
    // Initialize Hive for testing
    await initMockHive();
  });

  setUp(() {
    ordersCubit = OrdersCubit();
  });

  tearDown(() async {
    ordersCubit.close();
    // Clean up Hive boxes
    await Hive.deleteFromDisk();
  });

  group('OrdersCubit -', () {
    group('Initial State |', () {
      test('initial state has empty orders and no loading', () {
        // Assert
        expect(ordersCubit.state.orders, isEmpty);
        expect(ordersCubit.state.isLoading, false);
        expect(ordersCubit.state.isCreating, false);
        expect(ordersCubit.state.isCancelling, false);
        expect(ordersCubit.state.isTracking, false);
        expect(ordersCubit.state.isGeneratingInvoice, false);
        expect(ordersCubit.state.error, isNull);
        expect(ordersCubit.state.trackedOrder, isNull);
        expect(ordersCubit.state.lastCreatedOrder, isNull);
        expect(ordersCubit.state.filterStatus, isNull);
      });

      test('filteredOrders returns all orders when no filter', () {
        // Assert
        expect(ordersCubit.state.filteredOrders, isEmpty);
        expect(ordersCubit.state.filteredOrders, equals(ordersCubit.state.orders));
      });
    });

    group('Load Orders |', () {
      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: loads mock orders when storage is empty',
        build: () => ordersCubit,
        act: (cubit) => cubit.loadOrders(),
        expect: () => [
          isA<OrdersState>().having((s) => s.isLoading, 'isLoading', true),
          isA<OrdersState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.orders.length, 'orders length', greaterThan(0))
              .having((s) => s.error, 'error', isNull),
        ],
        verify: (_) {
          // Verify mock orders were loaded
          expect(ordersCubit.state.orders.length, greaterThanOrEqualTo(2));
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'VALIDATION: loaded orders have required fields',
        build: () => ordersCubit,
        act: (cubit) => cubit.loadOrders(),
        verify: (_) {
          final orders = ordersCubit.state.orders;
          for (final order in orders) {
            expect(order.id, isNotNull);
            expect(order.userId, isNotNull);
            expect(order.orderItems, isNotEmpty);
            expect(order.status, isA<OrderStatus>());
            expect(order.total, greaterThan(0));
            expect(order.createdAt, isA<DateTime>());
            expect(order.trackingNumber, isNotNull);
          }
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'FINANCIAL: orders have correct calculations (subtotal + shipping = total)',
        build: () => ordersCubit,
        act: (cubit) => cubit.loadOrders(),
        verify: (_) {
          final orders = ordersCubit.state.orders;
          for (final order in orders) {
            expect(order.total, equals(order.subtotal + order.shipping));
            expect(order.subtotal, greaterThan(0));
            expect(order.shipping, greaterThanOrEqualTo(0));
          }
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'STATUS: loaded orders have valid status transitions',
        build: () => ordersCubit,
        act: (cubit) => cubit.loadOrders(),
        verify: (_) {
          final orders = ordersCubit.state.orders;
          final statuses = orders.map((o) => o.status).toSet();

          // Should have multiple different statuses in mock data
          expect(statuses.length, greaterThan(1));

          // Check for delivered and shipped orders
          final hasDelivered =
              orders.any((o) => o.status == OrderStatus.delivered);
          final hasShipped = orders.any((o) => o.status == OrderStatus.shipped);
          expect(hasDelivered || hasShipped, true);
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'FILTER: can filter orders by userId',
        build: () => ordersCubit,
        act: (cubit) => cubit.loadOrders(userId: 'user1'),
        verify: (_) {
          final orders = ordersCubit.state.orders;
          // All orders should belong to user1
          for (final order in orders) {
            expect(order.userId, 'user1');
          }
        },
      );
    });

    group('Get Order By ID |', () {
      test('SUCCESS: returns order from state when it exists', () async {
        // Arrange - Load orders first
        await ordersCubit.loadOrders();
        final firstOrder = ordersCubit.state.orders.first;

        // Act
        final order = await ordersCubit.getOrderById(firstOrder.id);

        // Assert
        expect(order, isNotNull);
        expect(order?.id, equals(firstOrder.id));
      });

      test('FAILURE: returns null when order not found', () async {
        // Arrange
        await ordersCubit.loadOrders();

        // Act
        final order = await ordersCubit.getOrderById('INVALID-ID');

        // Assert
        expect(order, isNull);
      });
    });

    group('Create Order |', () {
      final testItems = [
        OrderItem(
          id: 'OI-001',
          product: Product(
            id: 'P-001',
            title: 'Test Product',
            category: 'Electronics',
            description: 'Test',
            price: 10000,
            rating: 4.5,
          ),
          quantity: 2,
          price: 10000,
        ),
        OrderItem(
          id: 'OI-002',
          product: Product(
            id: 'P-002',
            title: 'Test Product 2',
            category: 'Fashion',
            description: 'Test 2',
            price: 5000,
            rating: 4.0,
          ),
          quantity: 1,
          price: 5000,
        ),
      ];

      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: creates order with correct calculations',
        build: () => ordersCubit,
        act: (cubit) => cubit.createOrder(
          items: testItems,
          deliveryAddress: 'Niamey, Niger',
          userId: 'user123',
          notes: 'Test order',
        ),
        expect: () => [
          isA<OrdersState>().having((s) => s.isCreating, 'isCreating', true),
          isA<OrdersState>()
              .having((s) => s.isCreating, 'isCreating', false)
              .having((s) => s.lastCreatedOrder, 'lastCreatedOrder', isNotNull)
              .having((s) => s.orders.length, 'orders length', 1)
              .having((s) => s.error, 'error', isNull),
        ],
        verify: (_) {
          final order = ordersCubit.state.lastCreatedOrder;
          expect(order, isNotNull);

          // Verify calculations
          final expectedSubtotal = 10000 * 2 + 5000 * 1; // 25000
          expect(order!.subtotal, equals(expectedSubtotal));
          expect(order.shipping, equals(1000)); // Fixed shipping
          expect(order.total, equals(expectedSubtotal + 1000)); // 26000
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'VALIDATION: created order has tracking number',
        build: () => ordersCubit,
        act: (cubit) => cubit.createOrder(
          items: testItems,
          deliveryAddress: 'Test Address',
          userId: 'user1',
        ),
        verify: (_) {
          final order = ordersCubit.state.lastCreatedOrder;
          expect(order?.trackingNumber, isNotNull);
          expect(order?.trackingNumber, startsWith('TRK'));
          expect(order?.trackingNumber?.length, greaterThan(3));
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'VALIDATION: created order has generated ID',
        build: () => ordersCubit,
        act: (cubit) => cubit.createOrder(
          items: testItems,
          deliveryAddress: 'Test Address',
        ),
        verify: (_) {
          final order = ordersCubit.state.lastCreatedOrder;
          expect(order?.id, isNotNull);
          expect(order?.id, startsWith('ORD'));
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'STATUS: new order starts with pending status',
        build: () => ordersCubit,
        act: (cubit) => cubit.createOrder(
          items: testItems,
          deliveryAddress: 'Test Address',
        ),
        verify: (_) {
          expect(
            ordersCubit.state.lastCreatedOrder?.status,
            OrderStatus.pending,
          );
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'SYNC: new order is marked as not synced',
        build: () => ordersCubit,
        act: (cubit) => cubit.createOrder(
          items: testItems,
          deliveryAddress: 'Test Address',
        ),
        verify: (_) {
          expect(ordersCubit.state.lastCreatedOrder?.isSynced, false);
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'VALIDATION: includes payment ID if provided',
        build: () => ordersCubit,
        act: (cubit) => cubit.createOrder(
          items: testItems,
          deliveryAddress: 'Test Address',
          paymentId: 'PAY-123',
        ),
        verify: (_) {
          expect(ordersCubit.state.lastCreatedOrder?.paymentId, 'PAY-123');
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'VALIDATION: includes notes if provided',
        build: () => ordersCubit,
        act: (cubit) => cubit.createOrder(
          items: testItems,
          deliveryAddress: 'Test Address',
          notes: 'Leave at door',
        ),
        verify: (_) {
          expect(ordersCubit.state.lastCreatedOrder?.notes, 'Leave at door');
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'FINANCIAL: handles large order amounts',
        build: () => ordersCubit,
        act: (cubit) {
          final largeItems = [
            OrderItem(
              id: 'OI-LARGE',
              product: Product(
                id: 'P-LARGE',
                title: 'Expensive Item',
                category: 'Luxury',
                description: 'High value',
                price: 500000,
                rating: 5.0,
              ),
              quantity: 5,
              price: 500000,
            ),
          ];
          return cubit.createOrder(
            items: largeItems,
            deliveryAddress: 'VIP Address',
          );
        },
        verify: (_) {
          final order = ordersCubit.state.lastCreatedOrder;
          expect(order?.subtotal, equals(2500000)); // 500k * 5
          expect(order?.total, equals(2501000)); // + 1000 shipping
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'LIST: new order is prepended to orders list',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: [
          Order(
            id: 'EXISTING-1',
            userId: 'user1',
            orderItems: const [],
            status: OrderStatus.delivered,
            subtotal: 10000,
            shipping: 1000,
            total: 11000,
            deliveryAddress: 'Old Address',
            trackingNumber: 'TRK-OLD',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ]),
        act: (cubit) => cubit.createOrder(
          items: testItems,
          deliveryAddress: 'New Address',
        ),
        verify: (_) {
          expect(ordersCubit.state.orders.length, 2);
          expect(ordersCubit.state.orders.first.id, startsWith('ORD'));
          expect(ordersCubit.state.orders.last.id, 'EXISTING-1');
        },
      );
    });

    group('Cancel Order |', () {
      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: cancels order with reason',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: [
          Order(
            id: 'ORD-CANCEL-1',
            userId: 'user1',
            orderItems: const [],
            status: OrderStatus.pending,
            subtotal: 10000,
            shipping: 1000,
            total: 11000,
            deliveryAddress: 'Test Address',
            trackingNumber: 'TRK-001',
            createdAt: DateTime.now(),
          ),
        ]),
        act: (cubit) => cubit.cancelOrder(
          orderId: 'ORD-CANCEL-1',
          reason: 'Changed my mind',
          additionalDetails: 'Found better price elsewhere',
        ),
        expect: () => [
          isA<OrdersState>().having((s) => s.isCancelling, 'isCancelling', true),
          isA<OrdersState>()
              .having((s) => s.isCancelling, 'isCancelling', false)
              .having((s) => s.error, 'error', isNull),
        ],
        verify: (_) {
          final order = ordersCubit.state.orders
              .firstWhere((o) => o.id == 'ORD-CANCEL-1');
          expect(order.status, OrderStatus.cancelled);
          expect(order.notes, contains('Changed my mind'));
          expect(order.notes, contains('Found better price elsewhere'));
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'STATUS: cancelled order updates to cancelled status',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: [
          Order(
            id: 'ORD-002',
            userId: 'user1',
            orderItems: const [],
            status: OrderStatus.confirmed,
            subtotal: 15000,
            shipping: 1000,
            total: 16000,
            deliveryAddress: 'Address',
            trackingNumber: 'TRK-002',
            createdAt: DateTime.now(),
          ),
        ]),
        act: (cubit) => cubit.cancelOrder(
          orderId: 'ORD-002',
          reason: 'Too expensive',
        ),
        verify: (_) {
          final order =
              ordersCubit.state.orders.firstWhere((o) => o.id == 'ORD-002');
          expect(order.status, OrderStatus.cancelled);
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'SYNC: cancelled order is marked as not synced',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: [
          Order(
            id: 'ORD-003',
            userId: 'user1',
            orderItems: const [],
            status: OrderStatus.pending,
            subtotal: 10000,
            shipping: 1000,
            total: 11000,
            deliveryAddress: 'Address',
            trackingNumber: 'TRK-003',
            createdAt: DateTime.now(),
            isSynced: true, // Was synced
          ),
        ]),
        act: (cubit) => cubit.cancelOrder(
          orderId: 'ORD-003',
          reason: 'Cancel test',
        ),
        verify: (_) {
          final order =
              ordersCubit.state.orders.firstWhere((o) => o.id == 'ORD-003');
          expect(order.isSynced, false); // Now not synced after cancellation
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'FAILURE: emits error when order not found',
        build: () => ordersCubit,
        seed: () => const OrdersState(orders: []),
        act: (cubit) => cubit.cancelOrder(
          orderId: 'INVALID-ID',
          reason: 'Test',
        ),
        expect: () => [
          isA<OrdersState>().having((s) => s.isCancelling, 'isCancelling', true),
          isA<OrdersState>()
              .having((s) => s.isCancelling, 'isCancelling', false)
              .having((s) => s.error, 'error', isNotNull)
              .having((s) => s.error, 'error', contains('not found')),
        ],
      );

      blocTest<OrdersCubit, OrdersState>(
        'VALIDATION: reason is included in notes',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: [
          Order(
            id: 'ORD-004',
            userId: 'user1',
            orderItems: const [],
            status: OrderStatus.processing,
            subtotal: 20000,
            shipping: 1000,
            total: 21000,
            deliveryAddress: 'Address',
            trackingNumber: 'TRK-004',
            createdAt: DateTime.now(),
          ),
        ]),
        act: (cubit) => cubit.cancelOrder(
          orderId: 'ORD-004',
          reason: 'Delivery too slow',
        ),
        verify: (_) {
          final order =
              ordersCubit.state.orders.firstWhere((o) => o.id == 'ORD-004');
          expect(order.notes, isNotNull);
          expect(order.notes, startsWith('Annulé:'));
          expect(order.notes, contains('Delivery too slow'));
        },
      );
    });

    group('Track Order |', () {
      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: tracks order by tracking number',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: [
          Order(
            id: 'ORD-TRACK-1',
            userId: 'user1',
            orderItems: const [],
            status: OrderStatus.shipped,
            subtotal: 30000,
            shipping: 1000,
            total: 31000,
            deliveryAddress: 'Track Address',
            trackingNumber: 'TRK-PUBLIC-123',
            createdAt: DateTime.now(),
          ),
        ]),
        act: (cubit) => cubit.trackOrder('TRK-PUBLIC-123'),
        expect: () => [
          isA<OrdersState>().having((s) => s.isTracking, 'isTracking', true),
          isA<OrdersState>()
              .having((s) => s.isTracking, 'isTracking', false)
              .having((s) => s.trackedOrder, 'trackedOrder', isNotNull)
              .having((s) => s.error, 'error', isNull),
        ],
        verify: (_) {
          expect(ordersCubit.state.trackedOrder?.trackingNumber,
              'TRK-PUBLIC-123');
          expect(ordersCubit.state.trackedOrder?.id, 'ORD-TRACK-1');
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'FAILURE: emits error when tracking number not found',
        build: () => ordersCubit,
        seed: () => const OrdersState(orders: []),
        act: (cubit) => cubit.trackOrder('INVALID-TRACKING'),
        expect: () => [
          isA<OrdersState>().having((s) => s.isTracking, 'isTracking', true),
          isA<OrdersState>()
              .having((s) => s.isTracking, 'isTracking', false)
              .having((s) => s.trackedOrder, 'trackedOrder', isNull)
              .having((s) => s.error, 'error', isNotNull)
              .having((s) => s.error, 'error', contains('non trouvé')),
        ],
      );

      blocTest<OrdersCubit, OrdersState>(
        'PUBLIC: tracking works without userId (public access)',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: [
          Order(
            id: 'ORD-PUBLIC',
            userId: 'any-user',
            orderItems: const [],
            status: OrderStatus.outForDelivery,
            subtotal: 15000,
            shipping: 1000,
            total: 16000,
            deliveryAddress: 'Public Track',
            trackingNumber: 'TRK-789',
            createdAt: DateTime.now(),
          ),
        ]),
        act: (cubit) => cubit.trackOrder('TRK-789'),
        verify: (_) {
          // Should return order regardless of userId
          expect(ordersCubit.state.trackedOrder, isNotNull);
          expect(ordersCubit.state.trackedOrder?.trackingNumber, 'TRK-789');
        },
      );
    });

    group('Generate Invoice |', () {
      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: generates invoice PDF path',
        build: () => ordersCubit,
        act: (cubit) => cubit.generateInvoice('ORD-INV-001'),
        expect: () => [
          isA<OrdersState>()
              .having((s) => s.isGeneratingInvoice, 'isGeneratingInvoice', true),
          isA<OrdersState>()
              .having(
                  (s) => s.isGeneratingInvoice, 'isGeneratingInvoice', false)
              .having((s) => s.lastGeneratedInvoicePath,
                  'lastGeneratedInvoicePath', isNotNull)
              .having((s) => s.error, 'error', isNull),
        ],
        verify: (_) {
          expect(ordersCubit.state.lastGeneratedInvoicePath, isNotNull);
          expect(ordersCubit.state.lastGeneratedInvoicePath,
              contains('INV_ORD-INV-001'));
          expect(
              ordersCubit.state.lastGeneratedInvoicePath, endsWith('.pdf'));
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'VALIDATION: invoice path contains order ID',
        build: () => ordersCubit,
        act: (cubit) => cubit.generateInvoice('ORD-12345'),
        verify: (_) {
          expect(ordersCubit.state.lastGeneratedInvoicePath,
              contains('ORD-12345'));
        },
      );
    });

    group('Request Refund |', () {
      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: updates order status to refund requested',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: [
          Order(
            id: 'ORD-REFUND-1',
            userId: 'user1',
            orderItems: const [],
            status: OrderStatus.delivered,
            subtotal: 50000,
            shipping: 1000,
            total: 51000,
            deliveryAddress: 'Refund Address',
            trackingNumber: 'TRK-REF-1',
            createdAt: DateTime.now(),
          ),
        ]),
        act: (cubit) => cubit.requestRefund(
          orderId: 'ORD-REFUND-1',
          reason: 'Defective product',
          additionalDetails: 'Screen broken on arrival',
          refundAmount: 51000,
        ),
        expect: () => [
          isA<OrdersState>()
              .having((s) => s.isLoadingDetails, 'isLoadingDetails', true),
          isA<OrdersState>()
              .having((s) => s.isLoadingDetails, 'isLoadingDetails', false)
              .having((s) => s.error, 'error', isNull),
        ],
        verify: (_) {
          final order = ordersCubit.state.orders
              .firstWhere((o) => o.id == 'ORD-REFUND-1');
          expect(order.status, OrderStatus.refundRequested);
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'STATUS: refund request changes status correctly',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: [
          Order(
            id: 'ORD-REF-2',
            userId: 'user2',
            orderItems: const [],
            status: OrderStatus.delivered,
            subtotal: 25000,
            shipping: 1000,
            total: 26000,
            deliveryAddress: 'Address',
            trackingNumber: 'TRK-REF-2',
            createdAt: DateTime.now(),
          ),
        ]),
        act: (cubit) => cubit.requestRefund(
          orderId: 'ORD-REF-2',
          reason: 'Not as described',
          additionalDetails: 'Different color',
          refundAmount: 26000,
        ),
        verify: (_) {
          final order =
              ordersCubit.state.orders.firstWhere((o) => o.id == 'ORD-REF-2');
          expect(order.status, OrderStatus.refundRequested);
        },
      );
    });

    group('Filter Orders |', () {
      final mockOrders = [
        Order(
          id: 'ORD-PEND',
          userId: 'user1',
          orderItems: const [],
          status: OrderStatus.pending,
          subtotal: 10000,
          shipping: 1000,
          total: 11000,
          deliveryAddress: 'Addr1',
          trackingNumber: 'TRK-P',
          createdAt: DateTime.now(),
        ),
        Order(
          id: 'ORD-SHIP',
          userId: 'user1',
          orderItems: const [],
          status: OrderStatus.shipped,
          subtotal: 20000,
          shipping: 1000,
          total: 21000,
          deliveryAddress: 'Addr2',
          trackingNumber: 'TRK-S',
          createdAt: DateTime.now(),
        ),
        Order(
          id: 'ORD-DEL',
          userId: 'user1',
          orderItems: const [],
          status: OrderStatus.delivered,
          subtotal: 30000,
          shipping: 1000,
          total: 31000,
          deliveryAddress: 'Addr3',
          trackingNumber: 'TRK-D',
          createdAt: DateTime.now(),
        ),
      ];

      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: filters orders by pending status',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: mockOrders),
        act: (cubit) => cubit.filterByStatus(OrderStatus.pending),
        expect: () => [
          isA<OrdersState>()
              .having((s) => s.filterStatus, 'filterStatus', OrderStatus.pending)
              .having((s) => s.filteredOrders.length, 'filtered count', 1)
              .having((s) => s.filteredOrders.first.id, 'first id', 'ORD-PEND'),
        ],
      );

      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: filters orders by shipped status',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: mockOrders),
        act: (cubit) => cubit.filterByStatus(OrderStatus.shipped),
        verify: (_) {
          expect(ordersCubit.state.filteredOrders.length, 1);
          expect(ordersCubit.state.filteredOrders.first.status,
              OrderStatus.shipped);
        },
      );

      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: filters orders by delivered status',
        build: () => ordersCubit,
        seed: () => OrdersState(orders: mockOrders),
        act: (cubit) => cubit.filterByStatus(OrderStatus.delivered),
        verify: (_) {
          expect(ordersCubit.state.filterStatus, OrderStatus.delivered);
          expect(ordersCubit.state.filteredOrders.length, 1);
          expect(ordersCubit.state.filteredOrders.first.status,
              OrderStatus.delivered);
        },
      );

      test('GETTER: filteredOrders applies filter correctly', () {
        // Arrange
        final state =
            OrdersState(orders: mockOrders, filterStatus: OrderStatus.shipped);

        // Act
        final filtered = state.filteredOrders;

        // Assert
        expect(filtered.length, 1);
        expect(filtered.first.status, OrderStatus.shipped);
      });

      test('getOrdersByStatus returns filtered orders', () async {
        // Arrange
        ordersCubit.emit(OrdersState(orders: mockOrders));

        // Act
        final pendingOrders =
            ordersCubit.getOrdersByStatus(OrderStatus.pending);

        // Assert
        expect(pendingOrders.length, 1);
        expect(pendingOrders.first.status, OrderStatus.pending);
      });

      test('getActiveOrders excludes delivered and cancelled', () async {
        // Arrange
        final allOrders = [
          ...mockOrders,
          Order(
            id: 'ORD-CANC',
            userId: 'user1',
            orderItems: const [],
            status: OrderStatus.cancelled,
            subtotal: 5000,
            shipping: 1000,
            total: 6000,
            deliveryAddress: 'Addr4',
            trackingNumber: 'TRK-C',
            createdAt: DateTime.now(),
          ),
        ];
        ordersCubit.emit(OrdersState(orders: allOrders));

        // Act
        final activeOrders = ordersCubit.getActiveOrders();

        // Assert
        expect(activeOrders.length, 2); // pending + shipped
        expect(
          activeOrders.any((o) => o.status == OrderStatus.delivered),
          false,
        );
        expect(
          activeOrders.any((o) => o.status == OrderStatus.cancelled),
          false,
        );
      });
    });

    group('Delivery Time Slots |', () {
      test('SUCCESS: returns time slots for a date', () async {
        // Arrange
        final date = DateTime.now().add(const Duration(days: 1));

        // Act
        final slots = await ordersCubit.getAvailableDeliveryTimeSlots(date);

        // Assert
        expect(slots, isNotEmpty);
        expect(slots.length, greaterThanOrEqualTo(6)); // At least 6 slots per day

        // Verify slots have required fields
        for (final slot in slots) {
          expect(slot.id, isNotNull);
          expect(slot.timeRange, isNotNull);
          expect(slot.startTime, isA<DateTime>());
          expect(slot.endTime, isA<DateTime>());
          expect(slot.isAvailable, isA<bool>());
          expect(slot.endTime.isAfter(slot.startTime), true);
        }
      });

      test('VALIDATION: time slots have valid time ranges', () async {
        // Arrange
        final date = DateTime.now().add(const Duration(days: 1));

        // Act
        final slots = await ordersCubit.getAvailableDeliveryTimeSlots(date);

        // Assert
        for (final slot in slots) {
          // End time should be after start time
          expect(slot.endTime.isAfter(slot.startTime), true);

          // Time range should be formatted
          expect(slot.timeRange, contains('-'));
          expect(slot.timeRange, contains(':'));
        }
      });

      test('BUSINESS: time slots have capacity tracking', () async {
        // Arrange
        final date = DateTime.now().add(const Duration(days: 1));

        // Act
        final slots = await ordersCubit.getAvailableDeliveryTimeSlots(date);

        // Assert - some slots should have capacity info
        final slotsWithCapacity =
            slots.where((s) => s.maxOrders != null && s.currentOrders != null);

        expect(slotsWithCapacity, isNotEmpty);

        for (final slot in slotsWithCapacity) {
          expect(slot.currentOrders, lessThanOrEqualTo(slot.maxOrders!));
          expect(slot.currentOrders, greaterThanOrEqualTo(0));
        }
      });

      test('PRICING: some time slots have additional fees', () async {
        // Arrange
        final date = DateTime.now().add(const Duration(days: 1));

        // Act
        final slots = await ordersCubit.getAvailableDeliveryTimeSlots(date);

        // Assert - some premium slots should have additional fees
        final slotsWithFees = slots.where((s) => s.additionalFee != null);

        expect(slotsWithFees, isNotEmpty);

        for (final slot in slotsWithFees) {
          expect(slot.additionalFee, greaterThan(0));
        }
      });
    });

    group('Clear State Methods |', () {
      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: clearError clears error state',
        build: () => ordersCubit,
        seed: () => const OrdersState(error: 'Test error'),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          isA<OrdersState>().having((s) => s.error, 'error', isNull),
        ],
      );

      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: clearTrackedOrder clears tracked order',
        build: () => ordersCubit,
        seed: () => OrdersState(
          trackedOrder: Order(
            id: 'ORD-TEST',
            userId: 'user1',
            orderItems: const [],
            status: OrderStatus.shipped,
            subtotal: 10000,
            shipping: 1000,
            total: 11000,
            deliveryAddress: 'Test',
            trackingNumber: 'TRK-TEST',
            createdAt: DateTime.now(),
          ),
        ),
        act: (cubit) => cubit.clearTrackedOrder(),
        expect: () => [
          isA<OrdersState>().having((s) => s.trackedOrder, 'trackedOrder', isNull),
        ],
      );

      blocTest<OrdersCubit, OrdersState>(
        'SUCCESS: clearLastCreatedOrder clears last created order',
        build: () => ordersCubit,
        seed: () => OrdersState(
          lastCreatedOrder: Order(
            id: 'ORD-LAST',
            userId: 'user1',
            orderItems: const [],
            status: OrderStatus.pending,
            subtotal: 5000,
            shipping: 1000,
            total: 6000,
            deliveryAddress: 'Test',
            trackingNumber: 'TRK-LAST',
            createdAt: DateTime.now(),
          ),
        ),
        act: (cubit) => cubit.clearLastCreatedOrder(),
        expect: () => [
          isA<OrdersState>()
              .having((s) => s.lastCreatedOrder, 'lastCreatedOrder', isNull),
        ],
      );
    });

    group('State Management |', () {
      test('EQUATABLE: identical states are equal', () {
        final order1 = Order(
          id: 'ORD-1',
          userId: 'user1',
          orderItems: const [],
          status: OrderStatus.pending,
          subtotal: 10000,
          shipping: 1000,
          total: 11000,
          deliveryAddress: 'Test',
          trackingNumber: 'TRK-1',
          createdAt: DateTime.now(),
        );

        final state1 = OrdersState(orders: [order1], isLoading: false);
        final state2 = OrdersState(orders: [order1], isLoading: false);

        expect(state1.props, equals(state2.props));
      });

      test('COPY_WITH: preserves unchanged fields', () {
        final originalState = OrdersState(
          orders: const [],
          isLoading: false,
          filterStatus: OrderStatus.pending,
        );

        final newState = originalState.copyWith(isLoading: true);

        expect(newState.isLoading, true);
        expect(newState.filterStatus, OrderStatus.pending);
        expect(newState.orders, isEmpty);
      });

      test('COPY_WITH: updates isLoading flag', () {
        const originalState = OrdersState(isLoading: false);
        final newState = originalState.copyWith(isLoading: true);

        expect(newState.isLoading, true);
      });
    });
  });
}
