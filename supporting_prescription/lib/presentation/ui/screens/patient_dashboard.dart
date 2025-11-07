import 'dart:io';
import 'package:supporting_prescription/domain/entities/prescription.dart';

import '../../../domain/entities/patient.dart';
import '../../services/medication_service.dart';
import '../../services/prescription_service.dart';
import '../../services/reminder_service.dart';

class PatientMenu {
  final PrescriptionService _prescriptionService;
  final MedicationService _medicationService;
  final Patient _currentUser;
  
  PatientMenu(this._prescriptionService, this._medicationService, this._currentUser);
  
  void showMenu() {
    while (true) {
      // Show reminders every time the menu is displayed
      _showReminders();
      
      print('\n--- PATIENT DASHBOARD ---');
      print('Welcome, ${_currentUser.name}');
      print('1. View Prescriptions');
      print('2. View Today\'s Medications');
      print('3. Record Medication Taken');
      print('4. Request Renewal');
      print('5. Check Renewal Status');
      print('6. View Medication History & Adherence');
      print('7. Check Missed Medications');
      print('8. Logout');
      
      final choice = _getInput('Choose: ');
      
      switch (choice) {
        case '1': _viewPrescriptions(); break;
        case '2': _viewTodaysMeds(); break;
        case '3': _recordMedication(); break;
        case '4': _requestRenewal(); break;
        case '5': _checkRenewalStatus(); break;
        case '6': _viewMedicationHistory(); break;
        case '7': _checkMissedMedications(); break;
        case '8': 
          print('\nLogging out... Take care, ${_currentUser.name}!');
          return;
        default: print('Invalid choice!');
      }
    }
  }
  
  void _showReminders() {
    // Check for upcoming doses in the next hour
    ReminderService.checkReminders(_currentUser.id);
  }
  
  void _viewPrescriptions() {
    final prescriptions = _prescriptionService.getPrescriptionsByPatient(_currentUser.id);
    
    print('\n--- My Prescriptions ---');
    if (prescriptions.isEmpty) {
      print('No prescriptions found.');
      return;
    }
    
    for (final p in prescriptions) {
      final statusIcon = p.status.toString().contains('pending') ? '🟡' : 
                        p.status.toString().contains('dispensed') ? '✅' : '❌';
      print('$statusIcon ${p.id} - Status: ${p.status} - Date: ${p.dateIssued}');
      if (p.medications.isNotEmpty) {
        for (final med in p.medications) {
          print('  💊 ${med.name} ${med.strength}mg - ${med.dose.frequencyPerDay}x/day');
        }
      } else {
        print('  No medications');
      }
      print(''); // Empty line for separation
    }
  }
  
  void _viewTodaysMeds() {
    final allDoses = _medicationService.getTodayDoses(_currentUser.id);
    
    print('\n--- Today\'s Medications ---');
    
    if (allDoses.isEmpty) {
      print('No medications scheduled for today.');
      print('\nPossible reasons:');
      print('• No active prescriptions with medications');
      print('• Prescriptions not yet dispensed by pharmacist');
      print('• Medications not scheduled for today');
      return;
    }
    
    final pending = allDoses.where((d) => !d.isTaken).toList();
    final taken = allDoses.where((d) => d.isTaken).toList();
    
    if (pending.isNotEmpty) {
      print('\n🟡 PENDING:');
      for (final dose in pending) {
        final time = _formatTime(dose.scheduledTime);
        final medName = _getMedicationName(dose.medicationId);
        print('   $time - $medName');
      }
    }
    
    if (taken.isNotEmpty) {
      print('\n✅ TAKEN:');
      for (final dose in taken) {
        final time = _formatTime(dose.scheduledTime);
        final medName = _getMedicationName(dose.medicationId);
        print('   $time - $medName');
      }
    }
    
    // Show summary
    print('\n📊 Today\'s Summary: ${taken.length} taken, ${pending.length} pending');
    
    // Show adherence rate
    final adherence = _medicationService.getAdherenceRate(_currentUser.id);
    print('📈 Your overall adherence rate: ${adherence.toStringAsFixed(1)}%');
  }
  
  void _recordMedication() {
    final allDoses = _medicationService.getTodayDoses(_currentUser.id);
    final pending = allDoses.where((d) => !d.isTaken).toList();
    
    if (pending.isEmpty) {
      print('\n🎉 All medications for today have been taken!');
      return;
    }
    
    print('\n--- Record Medication Taken ---');
    print('Select medication to mark as taken:');
    
    for (int i = 0; i < pending.length; i++) {
      final dose = pending[i];
      final time = _formatTime(dose.scheduledTime);
      final medName = _getMedicationName(dose.medicationId);
      print('${i + 1}. $time - $medName');
    }
    print('${pending.length + 1}. Cancel');
    
    final choice = int.tryParse(_getInput('\nSelect dose: ')) ?? 0;
    
    if (choice == pending.length + 1) {
      print('Cancelled.');
      return;
    } else if (choice > 0 && choice <= pending.length) {
      final success = _medicationService.markDoseAsTaken(pending[choice - 1].id);
      if (success) {
        print('✅ Medication recorded as taken!');
      } else {
        print('❌ Failed to record medication.');
      }
    } else {
      print('Invalid selection!');
    }
  }
  
  void _requestRenewal() {
    final prescriptions = _prescriptionService.getPrescriptionsByPatient(_currentUser.id);
    
    if (prescriptions.isEmpty) {
      print('No prescriptions found.');
      return;
    }
    
    // Show only active prescriptions that can be renewed
    final activePrescriptions = prescriptions.where((p) => 
      p.status.toString().contains('dispensed') && 
      !p.isExpired
    ).toList();
    
    if (activePrescriptions.isEmpty) {
      print('No active prescriptions available for renewal.');
      return;
    }
    
    print('\n--- Active Prescriptions for Renewal ---');
    for (final p in activePrescriptions) {
      print('${p.id} - Issued: ${p.dateIssued}');
      for (final med in p.medications) {
        print('  💊 ${med.name}');
      }
    }
    
    final id = _getInput('\nEnter Prescription ID to renew: ');
    
    // Check if prescription exists and belongs to patient
    Prescription? prescription;
    for (final p in prescriptions) {
      if (p.id == id) {
        prescription = p;
        break;
      }
    }
    
    if (prescription == null) {
      print('Prescription not found or does not belong to you!');
      return;
    }
    
    final success = _medicationService.requestRenewal(_currentUser.id, id);
    if (success) {
      print('✅ Renewal requested successfully!');
    } else {
      print('❌ Failed to request renewal (may already be pending).');
    }
  }
  
  void _checkRenewalStatus() {
    final renewals = _medicationService.getRenewalRequests(_currentUser.id);
    
    print('\n--- Renewal Status ---');
    if (renewals.isEmpty) {
      print('No renewal requests.');
      return;
    }
    
    for (final r in renewals) {
      final statusIcon = r.status.toString().contains('approved') ? '✅' : 
                        r.status.toString().contains('denied') ? '❌' : '🟡';
      print('$statusIcon ${r.prescriptionId} - Status: ${r.status}');
      if (r.doctorNote != null && r.doctorNote!.isNotEmpty) {
        print('   Note: ${r.doctorNote}');
      }
    }
  }
  
  void _viewMedicationHistory() {
    final history = _medicationService.getDoseHistory(_currentUser.id);
    
    print('\n--- Medication History (Last 7 Days) ---');
    if (history.isEmpty) {
      print('No medication history found.');
      return;
    }
    
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    
    final recentHistory = history.where((dose) => 
      dose.scheduledTime.isAfter(weekAgo)
    ).toList();
    
    if (recentHistory.isEmpty) {
      print('No medications in the last 7 days.');
      return;
    }
    
    String currentDate = '';
    for (final dose in recentHistory) {
      final date = _formatDate(dose.scheduledTime);
      if (date != currentDate) {
        currentDate = date;
        print('\n📅 $currentDate:');
      }
      
      final status = dose.isTaken ? '✅' : '❌';
      final time = _formatTime(dose.scheduledTime);
      final medName = _getMedicationName(dose.medicationId);
      print('   $status $time - $medName');
    }
    
    final takenCount = recentHistory.where((d) => d.isTaken).length;
    final totalCount = recentHistory.length;
    final adherence = totalCount > 0 ? (takenCount / totalCount * 100) : 0;
    
    print('\n📊 7-Day Adherence: ${adherence.toStringAsFixed(1)}% ($takenCount/$totalCount doses taken)');
  }
  
  void _checkMissedMedications() {
    ReminderService.showMissedDoses(_currentUser.id);
  }
  
  String _getMedicationName(String medicationId) {
    try {
      final prescriptions = _prescriptionService.getAllPrescriptions();
      for (final prescription in prescriptions) {
        for (final medication in prescription.medications) {
          if (medication.id == medicationId) {
            return '${medication.name} ${medication.strength}mg';
          }
        }
      }
    } catch (e) {
      print('Error getting medication name: $e');
    }
    return 'Medication $medicationId';
  }
  
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour;
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
  
  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}