import '../../data/json_handler.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/user.dart';

class AuthService {
  User? _currentUser;
  
  bool login(String phone, String password) {
    try {
      final users = JsonHandler.loadUsers();
      _currentUser = users.firstWhere((u) => u.phone == phone && u.password == password);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  void registerUser(User user) {
    final users = JsonHandler.loadUsers();
    
    if (users.any((u) => u.phone == user.phone)) {
      throw Exception('Phone number already registered');
    }
    
    users.add(user);
    JsonHandler.saveUsers(users);
  }
  
  List<Patient> getPatients() {
    final users = JsonHandler.loadUsers();
    return users.whereType<Patient>().toList();
  }
  
  Patient? getPatient(String patientId) {
    final users = JsonHandler.loadUsers();
    try {
      return users.whereType<Patient>().firstWhere((p) => p.id == patientId);
    } catch (e) {
      return null;
    }
  }
  
  User? get currentUser => _currentUser;
  void logout() => _currentUser = null;
}