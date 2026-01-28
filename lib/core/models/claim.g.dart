// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClaimAdapter extends TypeAdapter<Claim> {
  @override
  final int typeId = 5;

  @override
  Claim read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Claim(
      id: fields[0] as String,
      patient: fields[1] as Patient,
      bills: (fields[2] as List).cast<BillItem>(),
      advances: (fields[3] as List).cast<AdvancePayment>(),
      settlements: (fields[4] as List).cast<Settlement>(),
      totalBill: fields[5] as double,
      totalAdvances: fields[6] as double,
      totalSettlements: fields[7] as double,
      pendingAmount: fields[8] as double,
      status: fields[9] as ClaimStatus,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Claim obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patient)
      ..writeByte(2)
      ..write(obj.bills)
      ..writeByte(3)
      ..write(obj.advances)
      ..writeByte(4)
      ..write(obj.settlements)
      ..writeByte(5)
      ..write(obj.totalBill)
      ..writeByte(6)
      ..write(obj.totalAdvances)
      ..writeByte(7)
      ..write(obj.totalSettlements)
      ..writeByte(8)
      ..write(obj.pendingAmount)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaimAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
