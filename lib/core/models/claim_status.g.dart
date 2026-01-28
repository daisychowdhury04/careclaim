// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClaimStatusAdapter extends TypeAdapter<ClaimStatus> {
  @override
  final int typeId = 4;

  @override
  ClaimStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ClaimStatus.draft;
      case 1:
        return ClaimStatus.submitted;
      case 2:
        return ClaimStatus.approved;
      case 3:
        return ClaimStatus.rejected;
      case 4:
        return ClaimStatus.partiallySettled;
      default:
        return ClaimStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, ClaimStatus obj) {
    switch (obj) {
      case ClaimStatus.draft:
        writer.writeByte(0);
        break;
      case ClaimStatus.submitted:
        writer.writeByte(1);
        break;
      case ClaimStatus.approved:
        writer.writeByte(2);
        break;
      case ClaimStatus.rejected:
        writer.writeByte(3);
        break;
      case ClaimStatus.partiallySettled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaimStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
