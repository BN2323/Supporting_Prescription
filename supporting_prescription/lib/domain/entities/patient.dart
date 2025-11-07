import '../enums/role.dart';
import '../enums/sex.dart';
import 'user.dart';

class Patient extends User {
  final String address;
  final DateTime dob;
  final Sex sex;
  
  Patient({required super.id, required super.name, required super.phone, required super.password,
         required this.address, required this.dob, required this.sex}) 
      : super(role: Role.patient);
}