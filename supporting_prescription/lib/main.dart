import 'dart:io';
import 'dart:io/stdio.dart';
import 'package:supporting_prescription/domain/enums/role.dart';
import 'package:supporting_prescription/presentation/services/auth_service.dart';
import 'package:supporting_prescription/presentation/services/medication_service.dart';
import 'package:supporting_prescription/presentation/services/prescription_service.dart';
import 'package:supporting_prescription/presentation/ui/screens/doctor_dashboard.dart';
import 'package:supporting_prescription/presentation/ui/screens/login_screen.dart';
import 'package:supporting_prescription/presentation/ui/screens/pharmacist_dashboard.dart';

import 'domain/entities/user.dart';
import 'domain/entities/doctor.dart';
import 'domain/entities/patient.dart';
import 'domain/entities/pharmacist.dart';

class MainMenu {
  final AuthService _authService;
  final PrescriptionService _prescriptionService;
  final MedicationService _medicationService;

  MainMenu(
    this._authService,
    this._prescriptionService,
    this._medicationService,
  );

  void run() {
    print('=== MEDICATION MANAGEMENT SYSTEM ===');
    print('Welcome to the Healthcare Management System\n');

    while (true) {
      print('Main Menu:');
      print('1. Login');
      print('2. Register as Patient');
      print('3. Register as Doctor');
      print('4. Register as Pharmacist');
      print('5. Exit');

      final choice = _getInput('Choose an option: ');

      switch (choice) {
        case '1':
          _handleLogin();
          break;
        case '2':
          _handlePatientRegistration();
          break;
        case '3':
          _handleDoctorRegistration();
          break;
        case '4':
          _handlePharmacistRegistration();
          break;
        case '5':
          print('\nThank you for using the Medication Management System. Goodbye!');
          return;
        default:
          print('Invalid choice! Please try again.\n');
      }
    }
  }

  void _handleLogin() {
    final loginScreen = LoginScreen(_authService);
    final user = loginScreen.show();

    if (user != null) {
      _redirectToRoleMenu(user);
    } else {
      print('Login failed. Please try again.\n');
    }
  }

  void _handlePatientRegistration() {
    final registrationScreen = PatientRegistrationScreen(_authService);
    final user = registrationScreen.show();

    if (user != null) {
      print('\nRegistration successful! Redirecting to your dashboard...\n');
      _redirectToRoleMenu(user);
    }
  }

  void _handleDoctorRegistration() {
    final registrationScreen = DoctorRegistrationScreen(_authService);
    final user = registrationScreen.show();

    if (user != null) {
      print('\nRegistration successful! Redirecting to your dashboard...\n');
      _redirectToRoleMenu(user);
    }
  }

  void _handlePharmacistRegistration() {
    final registrationScreen = PharmacistRegistrationScreen(_authService);
    final user = registrationScreen.show();

    if (user != null) {
      print('\nRegistration successful! Redirecting to your dashboard...\n');
      _redirectToRoleMenu(user);
    }
  }

  void _redirectToRoleMenu(User user) {
    switch (user.role) {
      case Role.doctor:
        final doctorMenu = DoctorMenu(
          _prescriptionService,
          _medicationService,
          _authService,
          user as Doctor,
        );
        doctorMenu.showMenu();
        break;
      case Role.patient:
        final patientMenu = PatientMenu(
          _prescriptionService,
          _medicationService,
          user as Patient,
        );
        patientMenu.showMenu();
        break;
      case Role.pharmacist:
        final pharmacistMenu = PharmacistMenu(
          _prescriptionService,
          _authService,
          user as Pharmacist,
        );
        pharmacistMenu.showMenu();
        break;
    }
    
    print('\nReturning to main menu...\n');
  }

  String _getInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync()?.trim() ?? '';
  }
}

void main() {
  // Initialize services
  final authService = AuthService();
  final prescriptionService = PrescriptionService();
  final medicationService = MedicationService();

  // Create and run main menu
  final mainMenu = MainMenu(
    authService,
    prescriptionService,
    medicationService,
  );

  mainMenu.run();
}