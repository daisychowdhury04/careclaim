// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advance_payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdvancePaymentAdapter extends TypeAdapter<AdvancePayment> {
  @override
  final int typeId = 2;

  @override
  AdvancePayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdvancePayment(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      amount: fields[2] as double,
      notes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AdvancePayment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvancePaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
