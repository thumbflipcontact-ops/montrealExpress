import 'package:abdoul_express/model/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abdoul_express/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:abdoul_express/features/payment/presentation/pages/payment_processing_page.dart';

class PaymentMethodSelectionPage extends StatelessWidget {
  final String orderId;
  final String userId;
  final double totalAmount;
  final Map<String, dynamic>? deliveryInfo;

  const PaymentMethodSelectionPage({
    super.key,
    required this.orderId,
    required this.userId,
    required this.totalAmount,
    this.deliveryInfo,
  });

  void _onMethodSelected(BuildContext context, String methodId) {
    context.read<PaymentCubit>().selectPaymentMethod(methodId);
  }

  void _proceedToPayment(BuildContext context) {
    final selectedMethodId = context
        .read<PaymentCubit>()
        .state
        .selectedMethodId;

    if (selectedMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un mode de paiement'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentProcessingPage(
          orderId: orderId,
          userId: userId,
          amount: totalAmount,
          methodId: selectedMethodId,
          deliveryInfo: deliveryInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mode de paiement'), centerTitle: true),
      body: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) {
          return Column(
            children: [
              // Order Summary
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total à payer',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${totalAmount.toStringAsFixed(0)} F CFA',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Payment Methods List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availablePaymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = availablePaymentMethods[index];
                    final isSelected = state.selectedMethodId == method.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? cs.primary : cs.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? cs.primary.withValues(alpha:0.05) : null,
                      ),
                      child: InkWell(
                        onTap: () => _onMethodSelected(context, method.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getIconForMethod(method.id),
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      method.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Radio<String>(
                                value: method.id,
                                groupValue: state.selectedMethodId,
                                onChanged: (value) {
                                  if (value != null) {
                                    _onMethodSelected(context, value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Proceed Button
              SafeArea(
                minimum: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _proceedToPayment(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
}
