// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final int typeId = 1;

  @override
  OrderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItem(
      id: fields[0] as String,
      product: fields[1] as Product,
      quantity: fields[2] as int,
      price: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.product)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 2;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      id: fields[0] as String,
      userId: fields[1] as String,
      status: fields[3] as OrderStatus,
      subtotal: fields[4] as double,
      shipping: fields[5] as double,
      total: fields[6] as double,
      deliveryAddressId: fields[7] as String?,
      deliveryAddress: fields[8] as String?,
      deliveryAddressObj: fields[9] as DeliveryAddress?,
      deliveryMethod: fields[10] as DeliveryMethod?,
      paymentId: fields[11] as String?,
      trackingNumber: fields[12] as String?,
      createdAt: fields[13] as DateTime,
      confirmedAt: fields[14] as DateTime?,
      shippedAt: fields[15] as DateTime?,
      deliveredAt: fields[16] as DateTime?,
      notes: fields[17] as String?,
      isSynced: fields[18] as bool,
      orderItems: fields[19] as List<OrderItem>,
    )..items = (fields[2] as HiveList?)?.castHiveList();
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.subtotal)
      ..writeByte(5)
      ..write(obj.shipping)
      ..writeByte(6)
      ..write(obj.total)
      ..writeByte(7)
      ..write(obj.deliveryAddressId)
      ..writeByte(8)
      ..write(obj.deliveryAddress)
      ..writeByte(9)
      ..write(obj.deliveryAddressObj)
      ..writeByte(10)
      ..write(obj.deliveryMethod)
      ..writeByte(11)
      ..write(obj.paymentId)
      ..writeByte(12)
      ..write(obj.trackingNumber)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.confirmedAt)
      ..writeByte(15)
      ..write(obj.shippedAt)
      ..writeByte(16)
      ..write(obj.deliveredAt)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderStatusAdapter extends TypeAdapter<OrderStatus> {
  @override
  final int typeId = 0;

  @override
  OrderStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderStatus.pending;
      case 1:
        return OrderStatus.confirmed;
      case 2:
        return OrderStatus.processing;
      case 3:
        return OrderStatus.preparing;
      case 4:
        return OrderStatus.readyForDelivery;
      case 5:
        return OrderStatus.outForDelivery;
      case 6:
        return OrderStatus.shipped;
      case 7:
        return OrderStatus.delivered;
      case 8:
        return OrderStatus.cancelled;
      case 9:
        return OrderStatus.refundRequested;
      case 10:
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, OrderStatus obj) {
    switch (obj) {
      case OrderStatus.pending:
        writer.writeByte(0);
        break;
      case OrderStatus.confirmed:
        writer.writeByte(1);
        break;
      case OrderStatus.processing:
        writer.writeByte(2);
        break;
      case OrderStatus.preparing:
        writer.writeByte(3);
        break;
      case OrderStatus.readyForDelivery:
        writer.writeByte(4);
        break;
      case OrderStatus.outForDelivery:
        writer.writeByte(5);
        break;
      case OrderStatus.shipped:
        writer.writeByte(6);
        break;
      case OrderStatus.delivered:
        writer.writeByte(7);
        break;
      case OrderStatus.cancelled:
        writer.writeByte(8);
        break;
      case OrderStatus.refundRequested:
        writer.writeByte(9);
        break;
      case OrderStatus.refunded:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
