// lib/domain/entities/patient.dart
import 'user.dart';
import '../enums/role.dart';

class Patient extends User {
  final String address;
  final DateTime dateOfBirth;

  Patient({
    required String id,
    required String name,
    required String phone,
    required String password,
    required this.address,
    required this.dateOfBirth,
  }) : super(
          id: id,
          name: name,
          phone: phone,
          password: password,
          role: Role.PATIENT,
        );

  // Calculate age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() {
    return '$name (Age: $age, $address)';
  }
}