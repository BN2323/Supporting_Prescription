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
      print('\n=== PHARMACIST DASHBOARD ===');
      print('Welcome, ${_currentUser.name}');
      print('1. View & Dispense Pending Prescriptions');
      print('2. View All Prescriptions');
      print('3. Logout');
      
      final choice = _getInput('Choose an option: ');
      
      switch (choice) {
        case '1': _viewAndDispensePending(); break;
        case '2': _viewAll(); break;
        case '3': 
          print('\nLogging out... Goodbye, ${_currentUser.name}!');
          return;
        default: print('Invalid choice!');
      }
    }
  }
  
  void _viewAndDispensePending() {
    final pending = _prescriptionService.getPrescriptionsByStatus(PrescriptionStatus.pending);
    
    if (pending.isEmpty) {
      print('\nNo pending prescriptions.');
      return;
    }
    
    while (true) {
      print('\n--- Pending Prescriptions ---');
      for (int i = 0; i < pending.length; i++) {
        final p = pending[i];
        final patient = _authService.getPatient(p.patientId);
        print('${i + 1}. ${p.id} - Patient: ${patient?.name}');
      }
      print('${pending.length + 1}. Back to main menu');
      
      final choice = int.tryParse(_getInput('\nSelect prescription to dispense: ')) ?? 0;
      
      if (choice == pending.length + 1) {
        return;
      } else if (choice > 0 && choice <= pending.length) {
        _prescriptionService.dispensePrescription(pending[choice - 1].id);
        print('Prescription dispensed!');
        return; // Go back after dispensing
      } else {
        print('Invalid selection!');
      }
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
      final statusIcon = p.status == PrescriptionStatus.pending ? '🟡' : 
                        p.status == PrescriptionStatus.dispensed ? '✅' : '❌';
      print('$statusIcon ${p.id} - ${patient?.name} - ${p.status}');
    }
  }

  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}