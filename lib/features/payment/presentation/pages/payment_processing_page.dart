import 'package:abdoul_express/model/payment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abdoul_express/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:abdoul_express/features/payment/presentation/pages/receipt_upload_page.dart';
import 'package:abdoul_express/core/app_state.dart';
import 'package:abdoul_express/model/order.dart';
import 'package:abdoul_express/model/delivery_address.dart';
import 'package:abdoul_express/features/orders/presentation/pages/order_confirmation_page.dart';

class PaymentProcessingPage extends StatefulWidget {
  final String orderId;
  final String userId;
  final double amount;
  final String methodId;
  final Map<String, dynamic>? deliveryInfo;

  const PaymentProcessingPage({
    super.key,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.methodId,
    this.deliveryInfo,
  });

  @override
  State<PaymentProcessingPage> createState() => _PaymentProcessingPageState();
}

class _PaymentProcessingPageState extends State<PaymentProcessingPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('💰 [PaymentProcessing] $message');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  PaymentMethod get _method {
    return availablePaymentMethods.firstWhere((m) => m.id == widget.methodId);
  }

  Future<void> _processPayment() async {
    if (_method.requiresReceipt) {
      // Navigate to receipt upload
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReceiptUploadPage(
            orderId: widget.orderId,
            userId: widget.userId,
            amount: widget.amount,
            methodId: widget.methodId,
            deliveryInfo: widget.deliveryInfo,
          ),
        ),
      );
      return;
    }

    if (widget.methodId == 'cash_on_delivery') {
      // Just create the payment and confirm
      await context.read<PaymentCubit>().createPayment(
        orderId: widget.orderId,
        userId: widget.userId,
        amount: widget.amount,
        methodId: widget.methodId,
      );

      if (mounted) {
        _showSuccessDialog();
      }
      return;
    }

    // Mobile Money payment
    if (_formKey.currentState!.validate()) {
      await context.read<PaymentCubit>().createPayment(
        orderId: widget.orderId,
        userId: widget.userId,
        amount: widget.amount,
        methodId: widget.methodId,
        transactionRef: _phoneController.text,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    _logDebug('Payment successful! Creating order and clearing cart...');

    // Create order from cart items
    final appController = AppState.of(context);
    final cartItems = appController.cartItems;

    _logDebug('Cart has ${cartItems.length} items before order creation');

    // Create order items from cart
    final orderItems = cartItems.map((cartItem) {
      return OrderItem(
        id: 'OI-${DateTime.now().millisecondsSinceEpoch}-${cartItem.product.id}',
        product: cartItem.product,
        quantity: cartItem.quantity,
        price: cartItem.product.price,
      );
    }).toList();

    _logDebug('Created ${orderItems.length} order items');

    // Create delivery address object if we have delivery info
    DeliveryAddress? deliveryAddress;
    if (widget.deliveryInfo != null) {
      final addressText = widget.deliveryInfo!['address'] as String? ?? '';
      final additionalInfo = widget.deliveryInfo!['additionalInfo'] as String? ?? '';

      // Combine address and additional info
      final fullAddressText = additionalInfo.isNotEmpty
          ? '$addressText, $additionalInfo'
          : addressText;

      deliveryAddress = DeliveryAddress(
        id: 'DA-${DateTime.now().millisecondsSinceEpoch}',
        name: widget.deliveryInfo!['name'] as String? ?? '',
        phone: widget.deliveryInfo!['phone'] as String? ?? '',
        address: fullAddressText,
        isDefault: false,
        createdAt: DateTime.now(),
      );
    }

    // Create the order
    final order = Order(
      id: widget.orderId,
      userId: widget.userId,
      orderItems: orderItems,
      status: widget.methodId == 'cash_on_delivery'
          ? OrderStatus.confirmed
          : OrderStatus.pending,
      subtotal: appController.subtotal,
      shipping: appController.shipping,
      total: appController.total,
      deliveryAddressObj: deliveryAddress,
      deliveryAddress: widget.deliveryInfo?['address'] as String?,
      paymentId: widget.methodId,
      createdAt: DateTime.now(),
      notes: widget.deliveryInfo?['notes'] as String?,
    );

    _logDebug('Order created: ${order.id}, Status: ${order.status.displayName}, Total: ${order.total} F CFA');

    // Clear the cart
    _logDebug('Clearing cart (${cartItems.length} items)...');
    for (final item in cartItems) {
      appController.removeFromCart(item.product.id);
    }
    _logDebug('Cart cleared. Remaining items: ${appController.cartItems.length}');

    // Navigate to order confirmation page
    _logDebug('Navigating to order confirmation page');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderConfirmationPage(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_method.name), centerTitle: true),
      body: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount Display
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Montant à payer',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.amount.toStringAsFixed(0)} F CFA',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Instructions
                  _buildInstructions(),

                  const SizedBox(height: 24),

                  // Payment Form (if needed)
                  if (_requiresPhoneInput()) _buildPhoneInput(),

                  const SizedBox(height: 24),

                  // Confirm Button
                  ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _method.requiresReceipt
                          ? 'Envoyer le reçu'
                          : 'Confirmer le paiement',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _requiresPhoneInput() {
    return widget.methodId == 'wave' ||
        widget.methodId == 'orange_money' ||
        widget.methodId == 'moov_money';
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéro de téléphone',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Ex: 90 12 34 56',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer votre numéro';
            }
            if (value.trim().length < 8) {
              return 'Numéro invalide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    String instructions;
    IconData icon;

    switch (widget.methodId) {
      case 'wave':
        icon = Icons.phone_android;
        instructions =
            '1. Composez *144# sur votre téléphone\n'
            '2. Sélectionnez "Payer"\n'
            '3. Entrez le montant: ${widget.amount.toStringAsFixed(0)} F CFA\n'
            '4. Confirmez le paiement';
        break;
      case 'orange_money':
        icon = Icons.phone_android;
        instructions =
            '1. Composez #144# sur votre téléphone\n'
            '2. Sélectionnez "Transfert d\'argent"\n'
            '3. Entrez le montant: ${widget.amount.toStringAsFixed(0)} F CFA\n'
            '4. Confirmez le paiement';
        break;
      case 'moov_money':
        icon = Icons.phone_android;
        instructions =
            '1. Composez *555# sur votre téléphone\n'
            '2. Sélectionnez "Payer"\n'
            '3. Entrez le montant: ${widget.amount.toStringAsFixed(0)} F CFA\n'
            '4. Confirmez le paiement';
        break;
      case 'bank_transfer':
        icon = Icons.account_balance;
        instructions =
            'Effectuez un virement vers:\n\n'
            'Banque: Banque Atlantique\n'
            'Compte: 123456789\n'
            'Nom: AbdoulExpress SARL\n\n'
            'Ensuite, envoyez une photo du reçu.';
        break;
      case 'cash_on_delivery':
        icon = Icons.local_shipping;
        instructions =
            'Vous paierez en espèces à la livraison.\n\n'
            'Montant exact: ${widget.amount.toStringAsFixed(0)} F CFA\n\n'
            'Assurez-vous d\'avoir le montant exact lors de la réception.';
        break;
      case 'manual_receipt':
        icon = Icons.receipt_long;
        instructions =
            'Prenez une photo claire de votre reçu de paiement.\n\n'
            'Assurez-vous que:\n'
            '- Le montant est visible\n'
            '- La date est lisible\n'
            '- Le numéro de transaction est clair';
        break;
      default:
        icon = Icons.info;
        instructions = 'Suivez les instructions pour compléter le paiement.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instructions,
              style: TextStyle(color: Colors.blue.shade900, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
