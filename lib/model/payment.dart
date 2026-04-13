// Payment method model
class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final bool requiresReceipt;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.requiresReceipt = false,
  });
}

// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  verified,
  rejected,
  completed,
  failed,
}

// Payment model
class Payment {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String methodId;
  final PaymentStatus status;
  final String? receiptUrl;
  final String? transactionRef;
  final String? description;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  const Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.methodId,
    required this.status,
    this.receiptUrl,
    this.transactionRef,
    this.description,
    required this.createdAt,
    this.verifiedAt,
  });

  Payment copyWith({
    String? id,
    String? orderId,
    String? userId,
    double? amount,
    String? methodId,
    PaymentStatus? status,
    String? receiptUrl,
    String? transactionRef,
    String? description,
    DateTime? createdAt,
    DateTime? verifiedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      methodId: methodId ?? this.methodId,
      status: status ?? this.status,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      transactionRef: transactionRef ?? this.transactionRef,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}

// Available payment methods
const List<PaymentMethod> availablePaymentMethods = [
  PaymentMethod(
    id: 'wave',
    name: 'Wave',
    description: 'Paiement mobile via Wave',
    iconPath: 'assets/icons/wave.png',
  ),
  PaymentMethod(
    id: 'orange_money',
    name: 'Orange Money',
    description: 'Paiement mobile via Orange Money',
    iconPath: 'assets/icons/orange_money.png',
  ),
  PaymentMethod(
    id: 'moov_money',
    name: 'Moov Money',
    description: 'Paiement mobile via Moov Money',
    iconPath: 'assets/icons/moov_money.png',
  ),
  PaymentMethod(
    id: 'bank_transfer',
    name: 'Virement Bancaire',
    description: 'Transfert bancaire avec reçu',
    iconPath: 'assets/icons/bank.png',
    requiresReceipt: true,
  ),
  PaymentMethod(
    id: 'cash_on_delivery',
    name: 'Paiement à la livraison',
    description: 'Payez en espèces à la réception',
    iconPath: 'assets/icons/cash.png',
  ),
  PaymentMethod(
    id: 'manual_receipt',
    name: 'Reçu Manuel',
    description: 'Envoyez une photo de votre reçu',
    iconPath: 'assets/icons/receipt.png',
    requiresReceipt: true,
  ),
];
