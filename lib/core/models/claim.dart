import 'package:careclaim/core/models/advance_payment.dart';
import 'package:careclaim/core/models/bill_item.dart';
import 'package:careclaim/core/models/claim_status.dart';
import 'package:careclaim/core/models/patient.dart';
import 'package:careclaim/core/models/settlement.dart';
import 'package:hive/hive.dart';

part 'claim.g.dart';

@HiveType(typeId: 5)
class Claim {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Patient patient;

  @HiveField(2)
  final List<BillItem> bills;

  @HiveField(3)
  final List<AdvancePayment> advances;

  @HiveField(4)
  final List<Settlement> settlements;

  @HiveField(5)
  final double totalBill;

  @HiveField(6)
  final double totalAdvances;

  @HiveField(7)
  final double totalSettlements;

  @HiveField(8)
  final double pendingAmount;

  @HiveField(9)
  final ClaimStatus status;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  const Claim({
    required this.id,
    required this.patient,
    this.bills = const [],
    this.advances = const [],
    this.settlements = const [],
    this.totalBill = 0,
    this.totalAdvances = 0,
    this.totalSettlements = 0,
    this.pendingAmount = 0,
    this.status = ClaimStatus.draft,
    required this.createdAt,
    required this.updatedAt,
  });
}

