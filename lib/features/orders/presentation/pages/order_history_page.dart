import 'package:abdoul_express/model/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abdoul_express/features/orders/presentation/cubit/orders_cubit.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatefulWidget {
  final String userId;

  const OrderHistoryPage({super.key, required this.userId});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().loadOrders(userId: widget.userId.isNotEmpty ? widget.userId : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Commandes'), centerTitle: true),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.filteredOrders.isEmpty) {
            final colorScheme = Theme.of(context).colorScheme;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune commande',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vos commandes apparaîtront ici',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _FilterChips(
                selectedStatus: state.filterStatus,
                onStatusSelected: (status) {
                  context.read<OrdersCubit>().filterByStatus(status);
                },
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.filteredOrders.length - 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = state.filteredOrders[index];
                    return _OrderCard(
                      order: order,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailPage(order: order),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final OrderStatus? selectedStatus;
  final ValueChanged<OrderStatus?> onStatusSelected;

  const _FilterChips({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildChip(context, 'Tous', null),
          const SizedBox(width: 8),
          _buildChip(context, 'En attente', OrderStatus.pending),
          const SizedBox(width: 8),
          _buildChip(context, 'Confirmé', OrderStatus.confirmed),
          const SizedBox(width: 8),
          _buildChip(context, 'En cours', OrderStatus.processing),
          const SizedBox(width: 8),
          _buildChip(context, 'Expédié', OrderStatus.shipped),
          const SizedBox(width: 8),
          _buildChip(context, 'Livré', OrderStatus.delivered),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, OrderStatus? status) {
    final isSelected = selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onStatusSelected(status),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.createdAt),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.orderItems.length} article(s)',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${order.total.toStringAsFixed(0)} F CFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (order.trackingNumber != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Suivi: ${order.trackingNumber}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = 'En attente';
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        text = 'Confirmé';
        break;
      case OrderStatus.processing:
        color = Colors.purple;
        text = 'En cours';
        break;
      case OrderStatus.preparing:
        color = Colors.purple;
        text = 'En préparation';
        break;
      case OrderStatus.readyForDelivery:
        color = Colors.indigo;
        text = 'Prête pour livraison';
        break;
      case OrderStatus.outForDelivery:
        color = Colors.teal;
        text = 'En livraison';
        break;
      case OrderStatus.shipped:
        color = Colors.teal;
        text = 'Expédié';
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = 'Livré';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = 'Annulé';
        break;
      case OrderStatus.refundRequested:
        color = Colors.deepOrange;
        text = 'Remboursement demandé';
        break;
      case OrderStatus.refunded:
        color = Colors.deepOrange;
        text = 'Remboursé';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
