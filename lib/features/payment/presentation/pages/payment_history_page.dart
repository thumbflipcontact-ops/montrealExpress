import 'package:abdoul_express/model/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abdoul_express/features/payment/presentation/cubit/payment_cubit.dart';

class PaymentHistoryPage extends StatefulWidget {
  final String userId;

  const PaymentHistoryPage({super.key, required this.userId});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().loadPaymentHistory(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des paiements'),
        centerTitle: true,
      ),
      body: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun paiement',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vos paiements apparaîtront ici',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final payment = state.payments[index];
              return _PaymentHistoryCard(payment: payment);
            },
          );
        },
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  final Payment payment;

  const _PaymentHistoryCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final method = availablePaymentMethods.firstWhere(
      (m) => m.id == payment.methodId,
      orElse: () => availablePaymentMethods.first,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => _showPaymentDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForMethod(payment.methodId),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(payment.createdAt),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: payment.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Montant',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${payment.amount.toStringAsFixed(0)} F CFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (payment.transactionRef != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Référence',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      payment.transactionRef!,
                      style: const TextStyle(fontSize: 12),
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

  void _showPaymentDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails du paiement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _DetailRow(label: 'ID', value: payment.id),
            _DetailRow(label: 'Commande', value: payment.orderId),
            _DetailRow(
              label: 'Montant',
              value: '${payment.amount.toStringAsFixed(0)} F CFA',
            ),
            _DetailRow(
              label: 'Méthode',
              value: availablePaymentMethods
                  .firstWhere((m) => m.id == payment.methodId)
                  .name,
            ),
            _DetailRow(label: 'Statut', value: _getStatusText(payment.status)),
            if (payment.transactionRef != null)
              _DetailRow(label: 'Référence', value: payment.transactionRef!),
            if (payment.description != null)
              _DetailRow(label: 'Description', value: payment.description!),
            _DetailRow(label: 'Date', value: _formatDate(payment.createdAt)),
            if (payment.verifiedAt != null)
              _DetailRow(
                label: 'Vérifié le',
                value: _formatDate(payment.verifiedAt!),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMethod(String methodId) {
    switch (methodId) {
      case 'wave':
      case 'orange_money':
      case 'moov_money':
        return Icons.phone_android;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'cash_on_delivery':
        return Icons.local_shipping;
      case 'manual_receipt':
        return Icons.receipt_long;
      default:
        return Icons.payment;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.processing:
        return 'En cours';
      case PaymentStatus.verified:
        return 'Vérifié';
      case PaymentStatus.rejected:
        return 'Rejeté';
      case PaymentStatus.completed:
        return 'Complété';
      case PaymentStatus.failed:
        return 'Échoué';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case PaymentStatus.pending:
        color = Colors.orange;
        text = 'En attente';
        break;
      case PaymentStatus.processing:
        color = Colors.blue;
        text = 'En cours';
        break;
      case PaymentStatus.verified:
      case PaymentStatus.completed:
        color = Colors.green;
        text = 'Vérifié';
        break;
      case PaymentStatus.rejected:
      case PaymentStatus.failed:
        color = Colors.red;
        text = 'Rejeté';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
