import 'package:hive/hive.dart';

part 'bill_item.g.dart';

@HiveType(typeId: 1)
class BillItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  const BillItem({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });
}

