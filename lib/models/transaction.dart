import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 10)
enum TransactionType {
  @HiveField(0)
  sale,
  @HiveField(1)
  refund,
  @HiveField(2)
  cashIn,
  @HiveField(3)
  cashOut,
  @HiveField(4)
  expense,
}

@HiveType(typeId: 11)
enum PaymentMethod {
  @HiveField(0)
  cash,
  @HiveField(1)
  mobileMoney,
  @HiveField(2)
  card,
  @HiveField(3)
  bankTransfer,
  @HiveField(4)
  other,
}

@HiveType(typeId: 12)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final TransactionType type;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final PaymentMethod paymentMethod;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String? orderId;

  @HiveField(7)
  final String? customerId;

  @HiveField(8)
  final String? reference;

  @HiveField(9)
  final bool isSynced;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.paymentMethod,
    this.description,
    required this.createdAt,
    this.orderId,
    this.customerId,
    this.reference,
    this.isSynced = false,
  });

  // Getters for UI display
  String get typeDisplayName {
    switch (type) {
      case TransactionType.sale:
        return 'Vente';
      case TransactionType.refund:
        return 'Remboursement';
      case TransactionType.cashIn:
        return 'Encaissement';
      case TransactionType.cashOut:
        return 'Décaissement';
      case TransactionType.expense:
        return 'Dépense';
    }
  }

  String get paymentMethodDisplayName {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Espèces';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.card:
        return 'Carte';
      case PaymentMethod.bankTransfer:
        return 'Virement';
      case PaymentMethod.other:
        return 'Autre';
    }
  }

  String get amountDisplay {
    final sign = (type == TransactionType.refund ||
                 type == TransactionType.cashOut ||
                 type == TransactionType.expense) ? '-' : '+';
    return '$sign${amount.toStringAsFixed(0)} F';
  }

  bool get isIncome => type == TransactionType.sale || type == TransactionType.cashIn;
  bool get isExpense => type == TransactionType.refund ||
                       type == TransactionType.cashOut ||
                       type == TransactionType.expense;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    PaymentMethod? paymentMethod,
    String? description,
    DateTime? createdAt,
    String? orderId,
    String? customerId,
    String? reference,
    bool? isSynced,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      reference: reference ?? this.reference,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, paymentMethod: $paymentMethod, createdAt: $createdAt)';
  }
}

@HiveType(typeId: 13)
class CashRegister extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double openingBalance;

  @HiveField(3)
  final double currentBalance;

  @HiveField(4)
  final DateTime openingTime;

  @HiveField(5)
  final DateTime? closingTime;

  @HiveField(6)
  final bool isOpen;

  @HiveField(7)
  final String? openedBy;

  CashRegister({
    required this.id,
    required this.name,
    required this.openingBalance,
    required this.currentBalance,
    required this.openingTime,
    this.closingTime,
    required this.isOpen,
    this.openedBy,
  });

  double get totalSales => currentBalance - openingBalance;

  String get balanceDisplay => '${currentBalance.toStringAsFixed(0)} F';

  CashRegister copyWith({
    String? id,
    String? name,
    double? openingBalance,
    double? currentBalance,
    DateTime? openingTime,
    DateTime? closingTime,
    bool? isOpen,
    String? openedBy,
  }) {
    return CashRegister(
      id: id ?? this.id,
      name: name ?? this.name,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      isOpen: isOpen ?? this.isOpen,
      openedBy: openedBy ?? this.openedBy,
    );
  }

  @override
  String toString() {
    return 'CashRegister(id: $id, name: $name, currentBalance: $currentBalance, isOpen: $isOpen)';
  }
}