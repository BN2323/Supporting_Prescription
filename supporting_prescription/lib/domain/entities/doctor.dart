import '../enums/role.dart';
import 'user.dart';

class Doctor extends User {
  final String licenseNumber;
  final String specialization;
  
  Doctor({required String id, required String name, required String phone, required String password,
        required this.licenseNumber, required this.specialization}) 
      : super(id: id, name: name, phone: phone, password: password, role: Role.doctor);
}