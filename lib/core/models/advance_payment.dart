import 'package:hive/hive.dart';

part 'advance_payment.g.dart';

@HiveType(typeId: 2)
class AdvancePayment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String? notes;

  const AdvancePayment({
    required this.id,
    required this.date,
    required this.amount,
    this.notes,
  });
}

