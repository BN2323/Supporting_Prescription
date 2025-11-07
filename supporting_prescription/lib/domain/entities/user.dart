import '../enums/role.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final String password;
  final Role role;
  
  User({required this.id, required this.name, required this.phone, required this.password, required this.role});
  
  // bool login(String inputPassword) => password == inputPassword;
}