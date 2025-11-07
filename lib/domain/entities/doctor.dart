// lib/domain/entities/doctor.dart
import 'user.dart';
import '../enums/role.dart';

class Doctor extends User {
  final String licenseNumber;
  final String specialization;

  Doctor({
    required String id,
    required String name,
    required String phone,
    required String password,
    required this.licenseNumber,
    required this.specialization,
  }) : super(
          id: id,
          name: name,
          phone: phone,
          password: password,
          role: Role.DOCTOR,
        );

  @override
  String toString() {
    return 'Dr. $name - $specialization (License: $licenseNumber)';
  }
}