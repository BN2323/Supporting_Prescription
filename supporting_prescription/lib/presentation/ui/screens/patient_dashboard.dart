import 'dart:io';
import 'package:supporting_prescription/domain/entities/dose.dart';
import 'package:supporting_prescription/domain/entities/dose_intake.dart';
import 'package:supporting_prescription/domain/entities/medication_item.dart';
import 'package:supporting_prescription/domain/entities/prescription.dart';
import 'package:supporting_prescription/domain/enums/medication_form.dart';
import 'package:supporting_prescription/domain/enums/prescription_status.dart';

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
    try {
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
      
      // Separate doses by prescription status
      final availableDoses = <DoseIntake>[];
      final pendingPrescriptionDoses = <DoseIntake>[];
      
      for (final dose in allDoses) {
        final prescription = _getPrescriptionForDose(dose);
        if (prescription == null) {
          print('⚠️ Warning: No prescription found for dose ${dose.id}');
          continue;
        }
        
        if (prescription.status == PrescriptionStatus.dispensed) {
          availableDoses.add(dose);
        } else {
          pendingPrescriptionDoses.add(dose);
        }
      }
      
      final pending = availableDoses.where((d) => !d.isTaken).toList();
      final taken = availableDoses.where((d) => d.isTaken).toList();
      
      // Show available medications (from dispensed prescriptions)
      if (pending.isNotEmpty) {
        print('\n🟡 AVAILABLE - READY TO TAKE:');
        for (final dose in pending) {
          final time = _formatTime(dose.scheduledTime);
          final medName = _getMedicationName(dose.medicationId);
          final timeLeft = dose.scheduledTime.difference(DateTime.now());
          final minutesLeft = timeLeft.inMinutes;
          
          String status = '';
          if (minutesLeft <= 0) {
            status = ' (OVERDUE)';
          } else if (minutesLeft <= 15) {
            status = ' (DUE SOON)';
          }
          
          print('   $time - $medName$status');
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
      
      // Show pending prescription medications (not yet dispensed)
      if (pendingPrescriptionDoses.isNotEmpty) {
        print('\n⏳ PENDING PRESCRIPTION - NOT YET AVAILABLE:');
        for (final dose in pendingPrescriptionDoses) {
          final time = _formatTime(dose.scheduledTime);
          final medName = _getMedicationName(dose.medicationId);
          final prescription = _getPrescriptionForDose(dose);
          final status = _getPrescriptionStatusText(prescription?.status);
          print('   $time - $medName (Status: $status)');
        }
        print('   💡 These medications will be available after pharmacist dispenses your prescription');
      }
      
      // Show summary
      print('\n📊 Today\'s Summary:');
      print('   • ${taken.length} taken');
      print('   • ${pending.length} available to take');
      print('   • ${pendingPrescriptionDoses.length} waiting for prescription approval');
      
      // Calculate and show today's adherence
      if (availableDoses.isNotEmpty) {
        final todayAdherence = _calculateTodayAdherence(availableDoses);
        print('📈 Today\'s adherence: ${todayAdherence.toStringAsFixed(1)}%');
      }
      
      // Show overall adherence rate
      final overallAdherence = _medicationService.getAdherenceRate(_currentUser.id);
      print('📊 Your overall adherence rate: ${overallAdherence.toStringAsFixed(1)}%');
      
    } catch (e) {
      print('❌ Error loading today\'s medications: $e');
    }
  }

  // Helper method to calculate today's adherence
  double _calculateTodayAdherence(List<DoseIntake> availableDoses) {
    if (availableDoses.isEmpty) return 0.0;
    
    final takenCount = availableDoses.where((d) => d.isTaken).length;
    return (takenCount / availableDoses.length) * 100;
  }

  // Helper method to get readable prescription status
  String _getPrescriptionStatusText(PrescriptionStatus? status) {
    if (status == null) return 'Unknown';
    
    switch (status) {
      case PrescriptionStatus.pending:
        return 'Pending Review';
      case PrescriptionStatus.dispensed:
        return 'Dispensed';
      case PrescriptionStatus.cancelled:
        return 'Cancelled';
      default:
        return status.toString().split('.').last;
    }
  }

  // Make sure _getPrescriptionForDose is implemented correctly
  Prescription? _getPrescriptionForDose(DoseIntake dose) {
    try {
      final prescriptions = _prescriptionService.getAllPrescriptions();
      for (final prescription in prescriptions) {
        for (final medication in prescription.medications) {
          if (medication.id == dose.medicationId) {
            return prescription;
          }
        }
      }
    } catch (e) {
      print('Error finding prescription for dose: $e');
    }
    return null;
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

void _recordMedication() {
    try {
      final allDoses = _medicationService.getTodayDoses(_currentUser.id);
      
      if (allDoses.isEmpty) {
        print('\nNo medications scheduled for today.');
        return;
      }
      
      // Filter only doses from dispensed prescriptions that aren't taken yet
      final availableDoses = allDoses.where((dose) {
        final prescription = _getPrescriptionForDose(dose);
        return prescription?.status == PrescriptionStatus.dispensed && !dose.isTaken;
      }).toList();
      
      // Filter pending prescription doses
      final pendingDoses = allDoses.where((dose) {
        final prescription = _getPrescriptionForDose(dose);
        return prescription?.status != PrescriptionStatus.dispensed && !dose.isTaken;
      }).toList();

      if (availableDoses.isEmpty) {
        print('\nNo medications available to take right now.');
        
        if (pendingDoses.isNotEmpty) {
          print('\n⏳ You have ${pendingDoses.length} medications waiting for prescription approval:');
          for (final dose in pendingDoses.take(3)) { // Show first 3
            final medName = _getMedicationName(dose.medicationId);
            final prescription = _getPrescriptionForDose(dose);
            final status = _getPrescriptionStatusText(prescription?.status);
            print('   • $medName (Status: $status)');
          }
          if (pendingDoses.length > 3) {
            print('   ... and ${pendingDoses.length - 3} more');
          }
          print('\n💡 Please wait for the pharmacist to dispense your prescription.');
        } else {
          print('🎉 All medications for today have been taken!');
          
          // Show taken medications for reference
          final takenDoses = allDoses.where((dose) => dose.isTaken).toList();
          if (takenDoses.isNotEmpty) {
            print('\n📋 Medications already taken today:');
            for (final dose in takenDoses) {
              final time = _formatTime(dose.scheduledTime);
              final medName = _getMedicationName(dose.medicationId);
              print('   ✅ $time - $medName');
            }
          }
        }
        return;
      }
      
      // Show medication recording interface
      _showMedicationRecordingInterface(availableDoses);
      
    } catch (e) {
      print('❌ Error accessing medication records: $e');
    }
  }

  void _showMedicationRecordingInterface(List<DoseIntake> availableDoses) {
    print('\n--- Record Medication Taken ---');
    
    // Check for overdue medications
    final now = DateTime.now();
    final overdueDoses = availableDoses.where((dose) => 
      dose.scheduledTime.isBefore(now)
    ).toList();
    
    if (overdueDoses.isNotEmpty) {
      print('🚨 You have ${overdueDoses.length} OVERDUE medication(s):');
      for (final dose in overdueDoses) {
        final time = _formatTime(dose.scheduledTime);
        final medName = _getMedicationName(dose.medicationId);
        final overdueBy = now.difference(dose.scheduledTime);
        final hoursOverdue = overdueBy.inHours;
        final minutesOverdue = overdueBy.inMinutes % 60;
        
        print('   ⚠️  $time - $medName (Overdue by ${hoursOverdue}h ${minutesOverdue}m)');
      }
      print('');
    }
    
    print('Select medication to mark as taken:');
    print('=' * 40);
    
    for (int i = 0; i < availableDoses.length; i++) {
      final dose = availableDoses[i];
      final time = _formatTime(dose.scheduledTime);
      final medName = _getMedicationName(dose.medicationId);
      
      // Add status indicators
      String status = '';
      final timeUntil = dose.scheduledTime.difference(now);
      
      if (timeUntil.isNegative) {
        status = ' 🚨 OVERDUE';
      } else if (timeUntil.inMinutes <= 30) {
        status = ' ⚠️  DUE SOON';
      }
      
      // Get prescription instructions if available
      final prescription = _getPrescriptionForDose(dose);
      String instructions = '';
      if (prescription != null) {
        final medication = prescription.medications.firstWhere(
          (med) => med.id == dose.medicationId,
          orElse: () => Medication(
            id: '',
            name: '',
            strength: 0,
            form: MedForm.tablet,
            dose: Dose(
              doseId: '',
              amount: 0,
              frequencyPerDay: 0,
              durationInDays: 0,
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              instructions: '',
            ),
          )
        );
        if (medication.dose.instructions.isNotEmpty) {
          instructions = '\n      Instructions: ${medication.dose.instructions}';
        }
      }
      
      print('${i + 1}. $time - $medName$status$instructions');
    }
    
    final cancelOption = availableDoses.length + 1;
    print('$cancelOption. Cancel');
    print('=' * 40);
    
    while (true) {
      final input = _getInput('\nSelect dose (1-$cancelOption): ');
      final choice = int.tryParse(input);
      
      if (choice == cancelOption) {
        print('Cancelled.');
        return;
      } else if (choice != null && choice > 0 && choice <= availableDoses.length) {
        final selectedDose = availableDoses[choice - 1];
        _confirmAndRecordDose(selectedDose);
        return;
      } else {
        print('❌ Invalid selection! Please enter a number between 1 and $cancelOption.');
      }
    }
  }

  void _confirmAndRecordDose(DoseIntake dose) {
    final medName = _getMedicationName(dose.medicationId);
    final time = _formatTime(dose.scheduledTime);
    
    print('\n--- Confirm Medication ---');
    print('Medication: $medName');
    print('Scheduled Time: $time');
    
    // Show if overdue
    final now = DateTime.now();
    if (dose.scheduledTime.isBefore(now)) {
      final overdueBy = now.difference(dose.scheduledTime);
      final hours = overdueBy.inHours;
      final minutes = overdueBy.inMinutes % 60;
      print('Status: 🚨 OVERDUE by ${hours}h ${minutes}m');
    } else {
      final timeUntil = dose.scheduledTime.difference(now);
      final minutes = timeUntil.inMinutes;
      print('Status: Due in $minutes minutes');
    }
    
    // Show instructions
    final prescription = _getPrescriptionForDose(dose);
    if (prescription != null) {
      final medication = prescription.medications.firstWhere(
        (med) => med.id == dose.medicationId,
        orElse: () => Medication(
          id: '',
          name: '',
          strength: 0,
          form: MedForm.tablet,
          dose: Dose(
            doseId: '',
            amount: 0,
            frequencyPerDay: 0,
            durationInDays: 0,
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            instructions: '',
          ),
        )
      );
      if (medication.dose.instructions.isNotEmpty) {
        print('Instructions: ${medication.dose.instructions}');
      }
    }
    
    print('\nAre you sure you want to mark this medication as taken?');
    print('1. Yes, mark as taken');
    print('2. No, go back');
    
    final confirmChoice = _getInput('Choose (1-2): ');
    
    if (confirmChoice == '1') {
      final success = _medicationService.markDoseAsTaken(dose.id);
      if (success) {
        print('\n✅ Medication recorded as taken!');
        
        // Show updated adherence
        final adherence = _medicationService.getAdherenceRate(_currentUser.id);
        print('📈 Your adherence rate: ${adherence.toStringAsFixed(1)}%');
        
        // Check if all medications are now taken
        final remainingDoses = _medicationService.getTodayDoses(_currentUser.id)
            .where((d) => !d.isTaken && _getPrescriptionForDose(d)?.status == PrescriptionStatus.dispensed)
            .length;
        
        if (remainingDoses == 0) {
          print('\n🎉 All medications for today have been taken! Great job! 🎉');
        }
      } else {
        print('\n❌ Failed to record medication. Please try again.');
      }
    } else {
      print('Returning to menu...');
    }
  }

  // Helper method (add this if not already present)
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
  
  
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
  
  
  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}