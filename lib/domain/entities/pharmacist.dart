// lib/domain/entities/pharmacist.dart
import 'user.dart';
import '../enums/role.dart';

class Pharmacist extends User {
  final String registrationId;

  Pharmacist({
    required String id,
    required String name,
    required String phone,
    required String password,
    required this.registrationId,
  }) : super(
          id: id,
          name: name,
          phone: phone,
          password: password,
          role: Role.PHARMACIST,
        );

  @override
  String toString() {
    return '$name (Pharmacist ID: $registrationId)';
  }
}