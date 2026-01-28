import 'package:hive/hive.dart';

part 'claim_status.g.dart';

@HiveType(typeId: 4)
enum ClaimStatus {
  @HiveField(0)
  draft,

  @HiveField(1)
  submitted,

  @HiveField(2)
  approved,

  @HiveField(3)
  rejected,

  @HiveField(4)
  partiallySettled,
}

