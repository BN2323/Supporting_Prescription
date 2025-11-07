import 'dart:io';
import 'dart:io/stdio.dart';

import 'domain/entities/doctor.dart';
import 'domain/entities/patient.dart';
import 'domain/enums/role.dart';
import 'presentation/services/auth_service.dart';
import 'presentation/services/medication_service.dart';
import 'presentation/services/prescription_service.dart';
import 'presentation/ui/screens/login_screen.dart';
import 'presentation/ui/screens/doctor_dashboard.dart';
import 'presentation/ui/screens/patient_dashboard.dart';
import 'presentation/ui/screens/pharmacist_dashboard.dart';

class PrescriptionTrackerApp {
  final AuthService _authService = AuthService();
  final PrescriptionService _prescriptionService = PrescriptionService();
  final MedicationService _medicationService = MedicationService();
  
  void run() {
    print('=== PRESCRIPTION TRACKING SYSTEM ===');
    
    while (true) {
      _showMainMenu();
    }
  }
  
  void _showMainMenu() {
    print('\n=== MAIN MENU ===');
    print('1. Login');
    print('2. Register Doctor');
    print('3. Register Patient');
    print('4. Register Pharmacist');
    print('5. Exit');
    
    final choice = _getInput('Choose option: ');
    
    switch (choice) {
      case '1': 
        _handleLogin();
        break;
      case '2': 
        _handleDoctorRegistration();
        break;
      case '3': 
        _handlePatientRegistration();
        break;
      case '4': 
        _handlePharmacistRegistration();
        break;
      case '5': 
        exit(0);
      default: 
        print('Invalid choice!');
    }
  }
  
  void _handleLogin() {
    final loginScreen = LoginScreen(_authService);
    final user = loginScreen.show();
    
    if (user != null) {
      _showRoleSpecificMenu();
    }
  }
  
  void _handleDoctorRegistration() {
    final screen = DoctorRegistrationScreen(_authService);
    final user = screen.show();
    
    if (user != null) {
      _showRoleSpecificMenu();
    }
  }
  
  void _handlePatientRegistration() {
    final screen = PatientRegistrationScreen(_authService);
    final user = screen.show();
    
    if (user != null) {
      _showRoleSpecificMenu();
    }
  }
  
  void _handlePharmacistRegistration() {
    final screen = PharmacistRegistrationScreen(_authService);
    final user = screen.show();
    
    if (user != null) {
      _showRoleSpecificMenu();
    }
  }
  
  void _showRoleSpecificMenu() {
    final user = _authService.currentUser!;
    
    switch (user.role) {
      case Role.doctor:
        final doctorMenu = DoctorMenu(_prescriptionService, _medicationService, _authService, user as Doctor);
        doctorMenu.showMenu();
        break;
      case Role.patient:
        final patientMenu = PatientMenu(_prescriptionService, _medicationService, user as Patient);
        patientMenu.showMenu();
        break;
      case Role.pharmacist:
        final pharmacistMenu = PharmacistMenu(_prescriptionService, _authService, user);
        pharmacistMenu.showMenu();
        break;
    }
    
    _authService.logout();
    print('Returned to main menu.');
  }
  
  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}

void main() {
  PrescriptionTrackerApp().run();
}