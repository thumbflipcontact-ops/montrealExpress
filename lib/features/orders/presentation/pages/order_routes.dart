import 'package:flutter/material.dart';
import 'order_confirmation_page.dart';
import 'order_tracking_page.dart';
import 'order_cancellation_page.dart';
import '../../../../model/order.dart';

class OrderRoutes {
  static const String orderConfirmation = '/order-confirmation';
  static const String orderTracking = '/order-tracking';
  static const String orderCancellation = '/order-cancellation';
  static const String orderDetails = '/order-details';
  static const String deliveryTimeSelection = '/delivery-time-selection';

  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      orderConfirmation: (context) {
        final order = ModalRoute.of(context)!.settings.arguments as Order;
        return OrderConfirmationPage(order: order);
      },
      orderTracking: (context) {
        final trackingNumber =
            ModalRoute.of(context)!.settings.arguments as String?;
        return OrderTrackingPage(trackingNumber: trackingNumber);
      },
      orderCancellation: (context) {
        final order = ModalRoute.of(context)!.settings.arguments as Order;
        return OrderCancellationPage(order: order);
      },
    };
  }

  static Future<T?> navigateToOrderConfirmation<T>(
    BuildContext context, {
    required Order order,
  }) {
    return Navigator.pushNamed<T>(context, orderConfirmation, arguments: order);
  }

  static Future<T?> navigateToOrderTracking<T>(
    BuildContext context, {
    String? trackingNumber,
  }) {
    return Navigator.pushNamed<T>(
      context,
      orderTracking,
      arguments: trackingNumber,
    );
  }

  static Future<T?> navigateToOrderCancellation<T>(
    BuildContext context, {
    required Order order,
  }) {
    return Navigator.pushNamed<T>(context, orderCancellation, arguments: order);
  }

  static void showOrderDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel();
              },
              child: Text(cancelText ?? 'Annuler'),
            ),
          if (onConfirm != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(confirmText ?? 'Confirmer'),
            ),
        ],
      ),
    );
  }

  static void showOrderBottomSheet({
    required BuildContext context,
    required Widget child,
    double? maxHeight,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: child,
          ),
        ),
      ),
    );
  }
}

class OrderNavigationHelper {
  static void showOrderStatusDialog({
    required BuildContext context,
    required Order order,
  }) {
    OrderRoutes.showOrderDialog(
      context: context,
      title: 'État de la commande',
      content:
          'Votre commande ${order.id} est actuellement: ${order.status.displayName}',
      confirmText: 'Suivre la commande',
      onConfirm: () {
        OrderRoutes.navigateToOrderTracking(
          context,
          trackingNumber: order.trackingNumber,
        );
      },
    );
  }

  static void showOrderOptionsBottomSheet({
    required BuildContext context,
    required Order order,
  }) {
    OrderRoutes.showOrderBottomSheet(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande #${order.id}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  order.status.displayName,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Voir les détails'),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              // Navigate to order details if implemented
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_searching),
            title: const Text('Suivre la commande'),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Facture'),
            onTap: () {
              Navigator.of(context).pop();
              // Navigate to invoice/receipt
            },
          ),
          if (_canCancelOrder(order))
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text(
                'Annuler la commande',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.of(context).pop();
                OrderRoutes.navigateToOrderCancellation(context, order: order);
              },
            ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Contacter le support'),
            onTap: () {
              Navigator.of(context).pop();
              // Implement contact support
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.readyForDelivery:
        return Colors.indigo;
      case OrderStatus.outForDelivery:
        return Colors.teal;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refundRequested:
      case OrderStatus.refunded:
        return Colors.deepOrange;
    }
  }

  static bool _canCancelOrder(Order order) {
    return order.status == OrderStatus.pending ||
        order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.preparing;
  }
}
