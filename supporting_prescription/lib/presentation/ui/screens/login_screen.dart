import 'dart:io';
import 'package:supporting_prescription/domain/entities/user.dart';

import '../../services/auth_service.dart';

class LoginScreen {
  final AuthService _authService;

  LoginScreen(this._authService);

  User? show() {
    print('\n--- Login ---');
    final phone = _getInput('Phone: ');
    final password = _getInput('Password: ');

    final success = _authService.login(phone, password);

    if (success) {
      final user = _authService.currentUser!;
      print('\nWelcome back, ${user.name}!');
      return user;
    } else {
      print('\nLogin failed! Please check your credentials.');
      return null;
    }
  }

  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}