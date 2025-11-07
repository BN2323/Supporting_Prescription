import '../enums/role.dart';
import '../enums/sex.dart';
import 'user.dart';

class Patient extends User {
  final String address;
  final DateTime dob;
  final Sex sex;
  
  Patient({required String id, required String name, required String phone, required String password,
         required this.address, required this.dob, required this.sex}) 
      : super(id: id, name: name, phone: phone, password: password, role: Role.patient);
}