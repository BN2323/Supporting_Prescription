import '../enums/role.dart';
import 'user.dart';

class Pharmacist extends User {
  final String registrationId;
  final String pharmacyName;
  
  Pharmacist({
    required String id, 
    required String name, 
    required String phone, 
    required String password,
    required this.registrationId,
    required this.pharmacyName
  }) : super(id: id, name: name, phone: phone, password: password, role: Role.pharmacist);
}