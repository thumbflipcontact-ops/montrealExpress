import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model/order.dart';
import '../cubit/orders_cubit.dart';

class OrderCancellationPage extends StatefulWidget {
  final Order order;

  const OrderCancellationPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderCancellationPage> createState() => _OrderCancellationPageState();
}

class _OrderCancellationPageState extends State<OrderCancellationPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  String _selectedReason = '';
  bool _isRequestingRefund = false;

  final List<String> _cancellationReasons = [
    'Changement d\'avis',
    'Produit défectueux',
    'Article ne correspond pas à la description',
    'Problème de livraison',
    'Commande par erreur',
    'Délai de livraison trop long',
    'Autre',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annuler la commande'),
        elevation: 1,
      ),
      body: BlocConsumer<OrdersCubit, OrdersState>(
        listener: (context, state) {
          if (state.isCancelling) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Annulation de la commande en cours...'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final canCancel = _canCancelOrder(widget.order);
          final canRequestRefund = _canRequestRefund(widget.order);

          if (!canCancel && !canRequestRefund) {
            return _buildCannotCancelPage(context, widget.order);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderInfo(context, widget.order),
                  const SizedBox(height: 24),
                  if (canCancel) _buildCancellationOptions(context),
                  if (canRequestRefund) _buildRefundOptions(context),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCannotCancelPage(BuildContext context, Order order) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.block,
                color: colorScheme.outline,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Impossible d\'annuler cette commande',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Cette commande est déjà ${order.status.displayName.toLowerCase()} et ne peut plus être annulée.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Si vous avez un problème avec cette commande, veuillez contacter notre service client.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Retour'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context, Order order) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de la commande',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order.id}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${_formatDate(order.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${order.totalAmount.toStringAsFixed(0)} F',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationOptions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Motif d\'annulation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._cancellationReasons.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(reason),
                leading: Radio<String>(
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value!;
                      _reasonController.text = value;
                    });
                  },
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            )),
            const SizedBox(height: 16),
            if (_selectedReason == 'Autre') ...[
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Veuillez préciser le motif',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez préciser le motif d\'annulation';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _additionalDetailsController,
              decoration: InputDecoration(
                labelText: 'Informations supplémentaires (optionnel)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Donnez-nous plus de détails sur votre demande...',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundOptions(BuildContext context) {
    if (!_canRequestRefund(widget.order)) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: const Text('Demander un remboursement'),
              subtitle: const Text('Cochez cette case si vous souhaitez être remboursé'),
              value: _isRequestingRefund,
              onChanged: (value) {
                setState(() {
                  _isRequestingRefund = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            if (_isRequestingRefund) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Le remboursement sera effectué dans les 5-7 jours ouvrables vers votre mode de paiement initial.',
                        style: TextStyle(color: Colors.blue[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isCancelling ? null : _submitCancellation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isCancelling
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Annulation en cours...'),
                        ],
                      )
                    : const Text('Confirmer l\'annulation'),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  bool _canCancelOrder(Order order) {
    return order.status == OrderStatus.pending ||
           order.status == OrderStatus.confirmed ||
           order.status == OrderStatus.processing;
  }

  bool _canRequestRefund(Order order) {
    return order.status == OrderStatus.delivered ||
           order.status == OrderStatus.readyForDelivery ||
           order.status == OrderStatus.outForDelivery;
  }

  Color _getStatusColor(OrderStatus status) {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _submitCancellation() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'annulation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Êtes-vous sûr de vouloir annuler cette commande ?'),
            const SizedBox(height: 12),
            if (_isRequestingRefund)
              const Text(
                'Un remboursement sera demandé et traité dans les plus brefs délais.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performCancellation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _performCancellation() {
    final cubit = context.read<OrdersCubit>();
    final reason = _reasonController.text.trim();
    final additionalDetails = _additionalDetailsController.text.trim();

    if (_isRequestingRefund) {
      cubit.requestRefund(
        orderId: widget.order.id,
        reason: reason,
        additionalDetails: additionalDetails,
        refundAmount: widget.order.total
  ,
      );
    }

    cubit.cancelOrder(
      orderId: widget.order.id,
      reason: reason,
      additionalDetails: additionalDetails,
    ).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isRequestingRefund
                ? 'Commande annulée et demande de remboursement soumise'
                : 'Commande annulée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }
}