import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:abdoul_express/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:abdoul_express/core/app_state.dart';
import 'package:abdoul_express/model/order.dart';
import 'package:abdoul_express/model/delivery_address.dart';
import 'package:abdoul_express/features/orders/presentation/pages/order_confirmation_page.dart';

class ReceiptUploadPage extends StatefulWidget {
  final String orderId;
  final String userId;
  final double amount;
  final String methodId;
  final Map<String, dynamic>? deliveryInfo;

  const ReceiptUploadPage({
    super.key,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.methodId,
    this.deliveryInfo,
  });

  @override
  State<ReceiptUploadPage> createState() => _ReceiptUploadPageState();
}

class _ReceiptUploadPageState extends State<ReceiptUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _transactionRefController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _receiptImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _transactionRefController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _receiptImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReceipt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter une photo du reçu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Create payment first
    await context.read<PaymentCubit>().createPayment(
      orderId: widget.orderId,
      userId: widget.userId,
      amount: widget.amount,
      methodId: widget.methodId,
      transactionRef: _transactionRefController.text,
    );

    final paymentId = context.read<PaymentCubit>().state.currentPayment?.id;

    if (paymentId != null) {
      // Upload receipt
      await context.read<PaymentCubit>().uploadReceipt(
        paymentId: paymentId,
        receiptPath: _receiptImage!.path,
        description: _descriptionController.text,
        transactionRef: _transactionRefController.text,
      );

      if (mounted) {
        setState(() => _isUploading = false);
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    // Create order from cart items
    final appController = AppState.of(context);
    final cartItems = appController.cartItems;

    // Create order items from cart
    final orderItems = cartItems.map((cartItem) {
      return OrderItem(
        id: 'OI-${DateTime.now().millisecondsSinceEpoch}-${cartItem.product.id}',
        product: cartItem.product,
        quantity: cartItem.quantity,
        price: cartItem.product.price,
      );
    }).toList();

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
      status: OrderStatus.pending, // Pending until receipt is verified
      subtotal: appController.subtotal,
      shipping: appController.shipping,
      total: appController.total,
      deliveryAddressObj: deliveryAddress,
      deliveryAddress: widget.deliveryInfo?['address'] as String?,
      paymentId: widget.methodId,
      createdAt: DateTime.now(),
      notes: widget.deliveryInfo?['notes'] as String?,
    );

    // Clear the cart
    for (final item in cartItems) {
      appController.removeFromCart(item.product.id);
    }

    // Navigate to order confirmation page
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
      appBar: AppBar(title: const Text('Envoyer le reçu'), centerTitle: true),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Envoi en cours...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Amount Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Montant payé'),
                          Text(
                            '${widget.amount.toStringAsFixed(0)} F CFA',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Receipt Image
                    Text(
                      'Photo du reçu *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: _receiptImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _receiptImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 48,
                                    color: cs.outline,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ajouter une photo',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (_receiptImage != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.edit),
                        label: const Text('Changer la photo'),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Transaction Reference
                    Text(
                      'Numéro de transaction',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _transactionRefController,
                      decoration: InputDecoration(
                        hintText: 'Ex: TRX123456789',
                        prefixIcon: const Icon(Icons.tag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer le numéro de transaction';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Description (optionnel)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ajoutez des détails sur le paiement...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Votre reçu sera vérifié sous 24h. Vous recevrez une notification.',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitReceipt,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Envoyer le reçu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
