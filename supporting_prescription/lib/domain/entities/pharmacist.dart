import '../enums/role.dart';
import 'user.dart';

class Pharmacist extends User {
  final String registrationId;
  final String pharmacyName;
  
  Pharmacist({
    required super.id, 
    required super.name, 
    required super.phone, 
    required super.password,
    required this.registrationId,
    required this.pharmacyName
  }) : super(role: Role.pharmacist);
}