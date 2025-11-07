import '../enums/role.dart';
import 'user.dart';

class Doctor extends User {
  final String licenseNumber;
  final String specialization;
  
  Doctor({required super.id, required super.name, required super.phone, required super.password,
        required this.licenseNumber, required this.specialization}) 
      : super(role: Role.doctor);
}