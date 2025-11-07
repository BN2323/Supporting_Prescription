import 'dart:io';
import '../../../domain/entities/patient.dart';
import '../../services/medication_service.dart';
import '../../services/prescription_service.dart';

class PatientMenu {
  final PrescriptionService _prescriptionService;
  final MedicationService _medicationService;
  final Patient _currentUser;
  
  PatientMenu(this._prescriptionService, this._medicationService, this._currentUser);
  
  void showMenu() {
    while (true) {
      print('\n--- PATIENT DASHBOARD ---');
      print('1. View Prescriptions');
      print('2. View Today\'s Medications');
      print('3. Record Medication Taken');
      print('4. Request Renewal');
      print('5. Check Renewal Status');
      print('6. Logout');
      
      final choice = _getInput('Choose: ');
      
      switch (choice) {
        case '1': _viewPrescriptions(); break;
        case '2': _viewTodaysMeds(); break;
        case '3': _recordMedication(); break;
        case '4': _requestRenewal(); break;
        case '5': _checkRenewalStatus(); break;
        case '6': return;
        default: print('Invalid choice!');
      }
    }
  }
  
  void _viewPrescriptions() {
    final prescriptions = _prescriptionService.getPrescriptionsByPatient(_currentUser.id);
    
    print('\n--- My Prescriptions ---');
    if (prescriptions.isEmpty) {
      print('No prescriptions found.');
      return;
    }
    
    for (final p in prescriptions) {
      print('${p.id} - Status: ${p.status}');
      for (final med in p.medications) {
        print('  - ${med.name} ${med.strength}mg');
      }
    }
  }
  
  void _viewTodaysMeds() {
    final doses = _medicationService.getTodayDoses(_currentUser.id);
    
    print('\n--- Today\'s Medications ---');
    if (doses.isEmpty) {
      print('No medications for today.');
      return;
    }
    
    for (final dose in doses) {
      final status = dose.isTaken ? 'TAKEN' : 'PENDING';
      print('${dose.id} - Status: $status');
    }
  }
  
  void _recordMedication() {
    final doses = _medicationService.getTodayDoses(_currentUser.id);
    final pending = doses.where((d) => !d.isTaken).toList();
    
    if (pending.isEmpty) {
      print('All medications taken!');
      return;
    }
    
    for (int i = 0; i < pending.length; i++) {
      print('${i + 1}. ${pending[i].id}');
    }
    
    final choice = int.tryParse(_getInput('Select dose: ')) ?? 0;
    if (choice > 0 && choice <= pending.length) {
      _medicationService.markDoseAsTaken(pending[choice - 1].id);
      print('Medication recorded!');
    }
  }
  
  void _requestRenewal() {
    final prescriptions = _prescriptionService.getPrescriptionsByPatient(_currentUser.id);
    
    if (prescriptions.isEmpty) {
      print('No prescriptions found.');
      return;
    }
    
    _viewPrescriptions();
    final id = _getInput('Prescription ID to renew: ');
    
    _medicationService.requestRenewal(_currentUser.id, id);
    print('Renewal requested!');
  }
  
  void _checkRenewalStatus() {
    final renewals = _medicationService.getRenewalRequests(_currentUser.id);
    
    print('\n--- Renewal Status ---');
    if (renewals.isEmpty) {
      print('No renewal requests.');
      return;
    }
    
    for (final r in renewals) {
      print('${r.prescriptionId} - Status: ${r.status}');
    }
  }
  
  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}