// lib/domain/entities/user.dart
import '../enums/role.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final Role role;
  
  // Private password - hidden from other files
  final String _password;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required String password,
    required this.role,
  }) : _password = password;

  // Public login method
  bool login(String inputPhone, String inputPassword) {
    return phone == inputPhone && _password == inputPassword;
  }

  @override
  String toString() {
    return '$name ($role)';
  }
}