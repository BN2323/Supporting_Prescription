import 'dart:io';
import 'package:supporting_prescription/domain/entities/doctor.dart';
import 'package:supporting_prescription/domain/entities/patient.dart';
import 'package:supporting_prescription/domain/entities/pharmacist.dart';
import 'package:supporting_prescription/domain/entities/user.dart';
import 'package:supporting_prescription/domain/enums/sex.dart';
import '../../services/auth_service.dart';

class DoctorRegistrationScreen {
  final AuthService _authService;

  DoctorRegistrationScreen(this._authService);

  User? show() {
    print('\n--- Doctor Registration ---');
    final name = _getInput('Full Name: ');
    final phone = _getInput('Phone: ');
    final password = _getInput('Password: ');
    final license = _getInput('License Number: ');
    final specialization = _getInput('Specialization: ');
    
    final doctor = Doctor(
      id: 'DOC${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      password: password,
      licenseNumber: license,
      specialization: specialization,
    );
    
    _authService.registerUser(doctor);
    print('\nDoctor registration successful!');
    
    final success = _authService.login(phone, password);
    if (success) {
      return _authService.currentUser;
    }
    return null;
  }

  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}

class PatientRegistrationScreen {
  final AuthService _authService;

  PatientRegistrationScreen(this._authService);

  User? show() {
    print('\n--- Patient Registration ---');
    final name = _getInput('Full Name: ');
    final phone = _getInput('Phone: ');
    final password = _getInput('Password: ');
    final address = _getInput('Address: ');
    
    final patient = Patient(
      id: 'PAT${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      password: password,
      address: address,
      dob: DateTime.now(),
      sex: Sex.male,
    );
    
    _authService.registerUser(patient);
    print('\nPatient registration successful!');
    
    final success = _authService.login(phone, password);
    if (success) {
      return _authService.currentUser;
    }
    return null;
  }

  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}

class PharmacistRegistrationScreen {
  final AuthService _authService;

  PharmacistRegistrationScreen(this._authService);

  User? show() {
    print('\n--- Pharmacist Registration ---');
    final name = _getInput('Full Name: ');
    final phone = _getInput('Phone: ');
    final password = _getInput('Password: ');
    final registrationId = _getInput('Registration ID: ');
    final pharmacyName = _getInput('Pharmacy Name: ');
    
    final pharmacist = Pharmacist(
      id: 'PHA${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      password: password,
      registrationId: registrationId,
      pharmacyName: pharmacyName,
    );
    
    _authService.registerUser(pharmacist);
    print('\nPharmacist registration successful!');
    
    final success = _authService.login(phone, password);
    if (success) {
      return _authService.currentUser;
    }
    return null;
  }

  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}