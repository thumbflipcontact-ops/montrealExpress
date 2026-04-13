import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/orders_cubit.dart';
import '../../../../model/order.dart';

class OrderTrackingPage extends StatefulWidget {
  final String? trackingNumber;

  const OrderTrackingPage({
    super.key,
    this.trackingNumber,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final TextEditingController _trackingController = TextEditingController();
  Order? _trackedOrder;

  @override
  void initState() {
    super.initState();
    if (widget.trackingNumber != null) {
      _trackingController.text = widget.trackingNumber!;
      _trackOrder(widget.trackingNumber!);
    }
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de commande'),
        elevation: 1,
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.isTracking) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Recherche de la commande...'),
                ],
              ),
            );
          }

          final orderToDisplay = state.trackedOrder ?? _trackedOrder;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTrackingSearch(context),
                      if (state.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (orderToDisplay != null) ...[
                SliverToBoxAdapter(
                  child: _buildOrderInfo(context, orderToDisplay),
                ),
                SliverToBoxAdapter(
                  child: _buildTrackingTimeline(context, orderToDisplay),
                ),
                SliverToBoxAdapter(
                  child: _buildDeliveryEstimate(context, orderToDisplay),
                ),
                SliverToBoxAdapter(
                  child: _buildActionButtons(context, orderToDisplay),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrackingSearch(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suivre votre commande',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _trackingController,
              decoration: InputDecoration(
                hintText: 'Entrez votre numéro de suivi',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    if (_trackingController.text.isNotEmpty) {
                      _trackOrder(_trackingController.text.trim());
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _trackOrder(value.trim());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context, Order order) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commande #${order.id}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.inventory_2,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '${order.items?.length} article${order.items!.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddressObj?.fullAddress ?? order.deliveryAddress ?? 'Non spécifié',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(BuildContext context, Order order) {
    final colorScheme = Theme.of(context).colorScheme;
    final steps = _getOrderSteps(order.status);
    final currentStepIndex = steps.indexWhere((step) => step.status == order.status);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statut de la livraison',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index <= currentStepIndex;
            final isCurrent = index == currentStepIndex;

            return _buildTimelineStep(
              context,
              step,
              isCompleted,
              isCurrent,
              index < steps.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context,
    OrderStep step,
    bool isCompleted,
    bool isCurrent,
    bool hasConnector,
  ) {
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
                    ? Colors.green
                    : isCurrent
                        ? Colors.blue
                        : colorScheme.outlineVariant,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : isCurrent
                      ? Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
            ),
            if (hasConnector)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : colorScheme.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted
                        ? Colors.green
                        : isCurrent
                            ? Colors.blue
                            : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                if (step.subtitle != null)
                  Text(
                    step.subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (step.estimatedTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        step.estimatedTime!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryEstimate(BuildContext context, Order order) {
    DateTime? estimatedDelivery;

    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.processing:
      case OrderStatus.preparing:
        estimatedDelivery = order.createdAt.add(
          Duration(hours: order.deliveryMethod?.estimatedHours ?? 24),
        );
        break;
      case OrderStatus.readyForDelivery:
        estimatedDelivery = DateTime.now().add(
          const Duration(hours: 4),
        );
        break;
      case OrderStatus.outForDelivery:
        estimatedDelivery = DateTime.now().add(
          const Duration(hours: 2),
        );
        break;
      case OrderStatus.shipped:
        estimatedDelivery = DateTime.now().add(
          const Duration(hours: 6),
        );
        break;
      case OrderStatus.delivered:
        break;
      case OrderStatus.cancelled:
      case OrderStatus.refundRequested:
      case OrderStatus.refunded:
        estimatedDelivery = null;
        break;
    }

    if (estimatedDelivery == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Livraison estimée',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(estimatedDelivery),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.blue[700],
            ),
          ),
          if (order.status == OrderStatus.outForDelivery) ...[
            const SizedBox(height: 8),
            Text(
              'Le livreur est en route vers votre adresse',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.blue[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (order.status == OrderStatus.outForDelivery) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _contactDelivery(context);
                },
                icon: const Icon(Icons.phone),
                label: const Text('Contacter le livreur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _viewOrderDetails(context, order);
              },
              icon: const Icon(Icons.list_alt),
              label: const Text('Voir les détails de la commande'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  List<OrderStep> _getOrderSteps(OrderStatus currentStatus) {
    final steps = <OrderStep>[
      const OrderStep(
        status: OrderStatus.confirmed,
        title: 'Commande confirmée',
        subtitle: 'Votre commande a été reçue et validée',
        icon: Icons.check_circle,
      ),
      const OrderStep(
        status: OrderStatus.preparing,
        title: 'En préparation',
        subtitle: 'Vos articles sont en cours de préparation',
        icon: Icons.inventory,
      ),
      const OrderStep(
        status: OrderStatus.readyForDelivery,
        title: 'Prête pour livraison',
        subtitle: 'La commande est prête et en attente de livraison',
        icon: Icons.local_shipping,
      ),
      const OrderStep(
        status: OrderStatus.outForDelivery,
        title: 'En livraison',
        subtitle: 'Votre commande est en route',
        icon: Icons.delivery_dining,
      ),
      const OrderStep(
        status: OrderStatus.delivered,
        title: 'Livrée',
        subtitle: 'Commande livrée avec succès',
        icon: Icons.done_all,
      ),
    ];

    // Return steps up to the current status
    final currentStepIndex = steps.indexWhere((step) => step.status == currentStatus);
    return steps.take(currentStepIndex + 1).toList();
  }

  void _trackOrder(String trackingNumber) {
    context.read<OrdersCubit>().trackOrder(trackingNumber);
  }

  void _contactDelivery(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter le livreur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Appeler'),
              onTap: () {
                Navigator.of(context).pop();
                // In a real app, implement phone call
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Envoyer un message'),
              onTap: () {
                Navigator.of(context).pop();
                // In a real app, implement messaging
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _viewOrderDetails(BuildContext context, Order order) {
    Navigator.pushNamed(
      context,
      '/order-details',
      arguments: order.id,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];

    return '${weekdays[dateTime.weekday - 1]} ${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class OrderStep {
  final OrderStatus status;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? estimatedTime;

  const OrderStep({
    required this.status,
    required this.title,
    this.subtitle,
    this.icon,
    this.estimatedTime,
  });
}