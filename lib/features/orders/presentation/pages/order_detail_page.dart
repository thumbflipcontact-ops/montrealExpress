import 'package:abdoul_express/core/widgets/product_image.dart';
import 'package:abdoul_express/model/order.dart';
import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande #${order.id.substring(0, 8)}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusTimeline(order: order),
            const Divider(height: 1),
            _OrderItems(items: order.orderItems),
            const Divider(height: 1),
            _DeliveryInfo(order: order),
            const Divider(height: 1),
            _OrderSummary(order: order),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final Order order;

  const _StatusTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'État de la commande',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _TimelineItem(
            title: 'Commande passée',
            date: order.createdAt,
            isCompleted: true,
            isLast: false,
          ),
          _TimelineItem(
            title: 'Confirmée',
            date: order.confirmedAt,
            isCompleted: order.confirmedAt != null,
            isLast: false,
          ),
          _TimelineItem(
            title: 'Expédiée',
            date: order.shippedAt,
            isCompleted: order.shippedAt != null,
            isLast: false,
          ),
          _TimelineItem(
            title: 'Livrée',
            date: order.deliveredAt,
            isCompleted: order.deliveredAt != null,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final DateTime? date;
  final bool isCompleted;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    this.date,
    required this.isCompleted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : colorScheme.outlineVariant,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date!),
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _OrderItems extends StatelessWidget {
  final List<OrderItem> items;

  const _OrderItems({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Articles (${items.length})',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProductImage(
                      imageUrl: item.product.imageUrl,
                      assetPath: item.product.imageAsset,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantité: ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.total.toStringAsFixed(0)} F CFA',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryInfo extends StatelessWidget {
  final Order order;

  const _DeliveryInfo({required this.order});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de livraison',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (order.deliveryAddress != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: colorScheme.onSurfaceVariant, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.deliveryAddress!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
          if (order.trackingNumber != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Suivi: ${order.trackingNumber}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final Order order;

  const _OrderSummary({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résumé',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            'Sous-total',
            '${order.subtotal.toStringAsFixed(0)} F CFA',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            'Livraison',
            '${order.shipping.toStringAsFixed(0)} F CFA',
          ),
          const Divider(height: 24),
          _SummaryRow(
            'Total',
            '${order.total.toStringAsFixed(0)} F CFA',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _SummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
