import 'dart:io';
import '../../../domain/entities/doctor.dart';
import '../../../domain/enums/medication_form.dart';
import '../../../domain/enums/prescription_status.dart';
import '../../services/auth_service.dart';
import '../../services/medication_service.dart';
import '../../services/prescription_service.dart';

class DoctorMenu {
  final PrescriptionService _prescriptionService;
  final MedicationService _medicationService;
  final AuthService _authService;
  final Doctor _currentUser;

  DoctorMenu(
    this._prescriptionService,
    this._medicationService,
    this._authService,
    this._currentUser,
  );

  void showMenu() {
    while (true) {
      print('\n--- DOCTOR DASHBOARD ---');
      print('1. Create Prescription');
      print('2. View My Prescriptions');
      print('3. Cancel Prescription');
      print('4. Manage Renewals');
      print('5. View Patients');
      print('6. Logout');
      
      final choice = _getInput('Choose: ');
      
      switch (choice) {
        case '1': _createPrescription(); break;
        case '2': _viewMyPrescriptions(); break;
        case '3': _cancelPrescription(); break;
        case '4': _manageRenewals(); break;
        case '5': _viewPatients(); break;
        case '6': return;
        default: print('Invalid choice!');
      }
    }
  }

  void _createPrescription() {
    print('\n--- Create Prescription ---');
    final patients = _authService.getPatients();
    
    if (patients.isEmpty) {
      print('No patients found.');
      return;
    }
    
    for (final patient in patients) {
      print('${patient.id} - ${patient.name}');
    }
    
    final patientId = _getInput('Patient ID: ');
    final deaNumber = _getInput('DEA Number: ');
    
    try {
      final patient = _authService.getPatient(patientId);
      if (patient == null) {
        print('Patient not found!');
        return;
      }
      
      final prescription = _prescriptionService.createPrescription(
        _currentUser.id, patientId, deaNumber
      );
      
      print('Prescription ${prescription.id} created!');
    } catch (e) {
      print('Error: $e');
    }
  }

  void _viewMyPrescriptions() {
    final prescriptions = _prescriptionService.getPrescriptionsByDoctor(_currentUser.id);
    
    print('\n--- My Prescriptions ---');
    if (prescriptions.isEmpty) {
      print('No prescriptions found.');
      return;
    }
    
    for (final p in prescriptions) {
      final patient = _authService.getPatient(p.patientId);
      print('${p.id} - Patient: ${patient?.name} - Status: ${p.status}');
    }
  }

  void _cancelPrescription() {
    final prescriptions = _prescriptionService.getPrescriptionsByDoctor(_currentUser.id);
    
    if (prescriptions.isEmpty) {
      print('No prescriptions to cancel.');
      return;
    }
    
    _viewMyPrescriptions();
    final id = _getInput('Prescription ID to cancel: ');
    
    try {
      _prescriptionService.cancelPrescription(id);
      print('Prescription cancelled!');
    } catch (e) {
      print('Error: $e');
    }
  }

  void _manageRenewals() {
    final renewals = _medicationService.getPendingRenewals();
    
    print('\n--- Pending Renewals ---');
    if (renewals.isEmpty) {
      print('No pending renewals.');
      return;
    }
    
    for (final r in renewals) {
      final patient = _authService.getPatient(r.patientId);
      print('${r.id} - Patient: ${patient?.name} - Prescription: ${r.prescriptionId}');
    }
    
    final renewalId = _getInput('Renewal ID: ');
    final decision = _getInput('Approve? (y/n): ');
    final notes = _getInput('Notes: ');
    
    _medicationService.processRenewal(renewalId, decision.toLowerCase() == 'y', notes);
    print('Renewal processed!');
  }

  void _viewPatients() {
    final patients = _authService.getPatients();
    
    print('\n--- Patients ---');
    if (patients.isEmpty) {
      print('No patients found.');
      return;
    }
    
    for (final patient in patients) {
      print('${patient.id} - ${patient.name} - ${patient.phone}');
    }
  }

  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}