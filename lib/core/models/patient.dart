import 'package:hive/hive.dart';

part 'patient.g.dart';

@HiveType(typeId: 0)
class Patient {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int? age;

  @HiveField(3)
  final String? gender;

  @HiveField(4)
  final String? contact;

  @HiveField(5)
  final String? policyDetails;

  const Patient({
    required this.id,
    required this.name,
    this.age,
    this.gender,
    this.contact,
    this.policyDetails,
  });
}

