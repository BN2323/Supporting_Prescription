import 'dart:io';
import '../../../domain/entities/user.dart';
import '../../../domain/enums/prescription_status.dart';
import '../../services/auth_service.dart';
import '../../services/prescription_service.dart';

class PharmacistMenu {
  final PrescriptionService _prescriptionService;
  final AuthService _authService;
  final User _currentUser;
  
  PharmacistMenu(this._prescriptionService, this._authService, this._currentUser);
  
  void showMenu() {
    while (true) {
      print('\n--- PHARMACIST DASHBOARD ---');
      print('1. View Pending Prescriptions');
      print('2. Dispense Prescription');
      print('3. View All Prescriptions');
      print('4. Logout');
      
      final choice = _getInput('Choose: ');
      
      switch (choice) {
        case '1': _viewPending(); break;
        case '2': _dispense(); break;
        case '3': _viewAll(); break;
        case '4': return;
        default: print('Invalid choice!');
      }
    }
  }
  
  void _viewPending() {
    final pending = _prescriptionService.getPrescriptionsByStatus(PrescriptionStatus.pending);
    
    print('\n--- Pending Prescriptions ---');
    if (pending.isEmpty) {
      print('No pending prescriptions.');
      return;
    }
    
    for (final p in pending) {
      final patient = _authService.getPatient(p.patientId);
      print('${p.id} - Patient: ${patient?.name}');
    }
  }
  
  void _dispense() {
    final pending = _prescriptionService.getPrescriptionsByStatus(PrescriptionStatus.pending);
    
    if (pending.isEmpty) {
      print('No prescriptions to dispense.');
      return;
    }
    
    _viewPending();
    final id = _getInput('Prescription ID: ');
    
    try {
      _prescriptionService.dispensePrescription(id);
      print('Prescription dispensed!');
    } catch (e) {
      print('Error: $e');
    }
  }
  
  void _viewAll() {
    final all = _prescriptionService.getAllPrescriptions();
    
    print('\n--- All Prescriptions ---');
    if (all.isEmpty) {
      print('No prescriptions found.');
      return;
    }
    
    for (final p in all) {
      final patient = _authService.getPatient(p.patientId);
      print('${p.id} - Patient: ${patient?.name} - Status: ${p.status}');
    }
  }
  
  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}