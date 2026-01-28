import 'package:hive/hive.dart';

part 'settlement.g.dart';

@HiveType(typeId: 3)
class Settlement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String? notes;

  const Settlement({
    required this.id,
    required this.date,
    required this.amount,
    this.notes,
  });
}

