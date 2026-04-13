// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 12;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      type: fields[1] as TransactionType,
      amount: fields[2] as double,
      paymentMethod: fields[3] as PaymentMethod,
      description: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      orderId: fields[6] as String?,
      customerId: fields[7] as String?,
      reference: fields[8] as String?,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paymentMethod)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.orderId)
      ..writeByte(7)
      ..write(obj.customerId)
      ..writeByte(8)
      ..write(obj.reference)
      ..writeByte(9)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CashRegisterAdapter extends TypeAdapter<CashRegister> {
  @override
  final int typeId = 13;

  @override
  CashRegister read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CashRegister(
      id: fields[0] as String,
      name: fields[1] as String,
      openingBalance: fields[2] as double,
      currentBalance: fields[3] as double,
      openingTime: fields[4] as DateTime,
      closingTime: fields[5] as DateTime?,
      isOpen: fields[6] as bool,
      openedBy: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CashRegister obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.openingBalance)
      ..writeByte(3)
      ..write(obj.currentBalance)
      ..writeByte(4)
      ..write(obj.openingTime)
      ..writeByte(5)
      ..write(obj.closingTime)
      ..writeByte(6)
      ..write(obj.isOpen)
      ..writeByte(7)
      ..write(obj.openedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashRegisterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 10;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.sale;
      case 1:
        return TransactionType.refund;
      case 2:
        return TransactionType.cashIn;
      case 3:
        return TransactionType.cashOut;
      case 4:
        return TransactionType.expense;
      default:
        return TransactionType.sale;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.sale:
        writer.writeByte(0);
        break;
      case TransactionType.refund:
        writer.writeByte(1);
        break;
      case TransactionType.cashIn:
        writer.writeByte(2);
        break;
      case TransactionType.cashOut:
        writer.writeByte(3);
        break;
      case TransactionType.expense:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 11;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.cash;
      case 1:
        return PaymentMethod.mobileMoney;
      case 2:
        return PaymentMethod.card;
      case 3:
        return PaymentMethod.bankTransfer;
      case 4:
        return PaymentMethod.other;
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.cash:
        writer.writeByte(0);
        break;
      case PaymentMethod.mobileMoney:
        writer.writeByte(1);
        break;
      case PaymentMethod.card:
        writer.writeByte(2);
        break;
      case PaymentMethod.bankTransfer:
        writer.writeByte(3);
        break;
      case PaymentMethod.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
