// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_method.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryMethodAdapter extends TypeAdapter<DeliveryMethod> {
  @override
  final int typeId = 5;

  @override
  DeliveryMethod read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeliveryMethod(
      type: fields[0] as DeliveryType,
      name: fields[1] as String,
      cost: fields[2] as double,
      estimatedHours: fields[3] as int,
      isAvailable: fields[4] as bool,
      description: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryMethod obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.cost)
      ..writeByte(3)
      ..write(obj.estimatedHours)
      ..writeByte(4)
      ..write(obj.isAvailable)
      ..writeByte(5)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeliveryTypeAdapter extends TypeAdapter<DeliveryType> {
  @override
  final int typeId = 4;

  @override
  DeliveryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeliveryType.standard;
      case 1:
        return DeliveryType.express;
      case 2:
        return DeliveryType.pickup;
      default:
        return DeliveryType.standard;
    }
  }

  @override
  void write(BinaryWriter writer, DeliveryType obj) {
    switch (obj) {
      case DeliveryType.standard:
        writer.writeByte(0);
        break;
      case DeliveryType.express:
        writer.writeByte(1);
        break;
      case DeliveryType.pickup:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
