import 'dart:io';
import 'package:supporting_prescription/domain/entities/prescription.dart';

import '../../../domain/entities/doctor.dart';
import '../../../domain/entities/patient.dart';
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
      print('\n=== DOCTOR DASHBOARD ===');
      print('Welcome, ${_currentUser.name}');
      print('1. Create Prescription');
      print('2. View & Manage Prescriptions');
      print('3. Manage Renewal Requests');
      print('4. View Patients');
      print('5. Logout');
      
      final choice = _getInput('Choose an option: ');
      
      switch (choice) {
        case '1': _createPrescription(); break;
        case '2': _viewAndManagePrescriptions(); break;
        case '3': _manageRenewals(); break;
        case '4': _viewPatients(); break;
        case '5': 
          print('\nLogging out... Goodbye, ${_currentUser.name}!');
          return;
        default: print('Invalid choice!');
      }
    }
  }

  void _createPrescription() {
    print('\n--- Create New Prescription ---');
    
    final patients = _authService.getPatients();
    
    if (patients.isEmpty) {
      print('No patients found.');
      return;
    }
    
    print('Available Patients:');
    for (final patient in patients) {
      print('${patient.id} - ${patient.name}');
    }
    
    final patientId = _getInput('\nEnter Patient ID: ');
    final patient = _authService.getPatient(patientId);
    
    if (patient == null) {
      print('Patient not found!');
      return;
    }
    
    final deaNumber = _getInput('Enter DEA Number: ');
    
    try {
      final prescription = _prescriptionService.createPrescription(
        _currentUser.id, patientId, deaNumber
      );
      
      if (prescription != null) {
        print('✅ Prescription ${prescription.id} created!');
        
        final addMeds = _getInput('Add medications now? (y/n): ');
        if (addMeds.toLowerCase() == 'y') {
          _addMedicationToPrescription(prescription.id);
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _viewAndManagePrescriptions() {
    // Helper to get fresh data
    List<Prescription> getCurrentPrescriptions() {
      return _prescriptionService.getPrescriptionsByDoctor(_currentUser.id);
    }
    
    var prescriptions = getCurrentPrescriptions();
    
    if (prescriptions.isEmpty) {
      print('\nNo prescriptions found.');
      return;
    }
    
    while (true) {
      print('\n--- My Prescriptions ---');
      
      // Refresh the list to get any updates
      prescriptions = getCurrentPrescriptions();
      
      for (int i = 0; i < prescriptions.length; i++) {
        final p = prescriptions[i];
        final patient = _authService.getPatient(p.patientId);
        final statusIcon = p.status == PrescriptionStatus.pending ? '🟡' : 
                          p.status == PrescriptionStatus.dispensed ? '✅' : '❌';
        print('${i + 1}. $statusIcon ${p.id} - ${patient?.name} - ${p.status}');
        
        // Show medications count for quick overview
        if (p.medications.isNotEmpty) {
          print('   Medications: ${p.medications.length}');
          for (final med in p.medications.take(2)) { // Show first 2 medications
            print('     💊 ${med.name}');
          }
          if (p.medications.length > 2) {
            print('     ... and ${p.medications.length - 2} more');
          }
        }
      }
      print('${prescriptions.length + 1}. Back to main menu');
      
      final choice = int.tryParse(_getInput('\nSelect prescription to view (or ${prescriptions.length + 1} to go back): ')) ?? 0;
      
      if (choice == prescriptions.length + 1) {
        return;
      } else if (choice > 0 && choice <= prescriptions.length) {
        _viewPrescriptionDetails(prescriptions[choice - 1]);
        // Refresh list after returning from details view
        prescriptions = getCurrentPrescriptions();
      } else {
        print('Invalid selection!');
      }
    }
  }
  void _viewPrescriptionDetails(Prescription prescription) {
    // Helper to get fresh prescription data
    Prescription? getCurrentPrescription() {
      return _prescriptionService.getPrescription(prescription.id);
    }
    
    var currentPrescription = getCurrentPrescription();
    if (currentPrescription == null) {
      print('Prescription not found!');
      return;
    }
    
    while (true) {
      // Use currentPrescription instead of the original prescription parameter
      final patient = _authService.getPatient(currentPrescription!.id);
      
      print('\n--- Prescription Details ---');
      print('ID: ${currentPrescription.id}');
      print('Patient: ${patient?.name}');
      print('Status: ${currentPrescription.status}');
      print('Date: ${currentPrescription.dateIssued}');
      print('DEA: ${currentPrescription.deaNumber}');
      
      if (currentPrescription.medications.isNotEmpty) {
        print('\nMedications:');
        for (final med in currentPrescription.medications) {
          print('  💊 ${med.name} ${med.strength}mg - ${med.form}');
          print('     Dose: ${med.dose.amount}mg, ${med.dose.frequencyPerDay}x/day');
          print('     Instructions: ${med.dose.instructions}');
        }
      } else {
        print('\nNo medications added.');
      }
      
      print('\nOptions:');
      print('1. Add Medication');
      print('2. Cancel Prescription');
      print('3. Back to list');
      
      final choice = _getInput('Choose: ');
      
      switch (choice) {
        case '1': 
          _addMedicationToPrescription(currentPrescription.id);
          // Reload the prescription after adding medication
          currentPrescription = getCurrentPrescription();
          if (currentPrescription == null) {
            print('Error: Prescription not found after update!');
            return;
          }
          break;
        case '2': 
          _cancelPrescription(currentPrescription.id);
          return; // Go back to list after cancellation
        case '3': 
          return;
        default: 
          print('Invalid choice!');
      }
    }
  }
  void _addMedicationToPrescription(String prescriptionId) {
    print('\n--- Add Medication ---');
    
    final name = _getInput('Medication Name: ');
    
    // Better input handling for numbers
    final strengthInput = _getInput('Strength (mg): ');
    final strength = double.tryParse(strengthInput) ?? 0.0;
    if (strength <= 0) {
      print('❌ Invalid strength! Using default 1.0 mg');
    }
    
    print('Available Forms:');
    for (int i = 0; i < MedForm.values.length; i++) {
      print('${i + 1}. ${MedForm.values[i]}');
    }
    
    final formInput = _getInput('Select form: ');
    final formIndex = int.tryParse(formInput) ?? 1;
    final form = formIndex > 0 && formIndex <= MedForm.values.length 
        ? MedForm.values[formIndex - 1] 
        : MedForm.tablet;
    
    final amountInput = _getInput('Dose Amount (mg): ');
    final amount = double.tryParse(amountInput) ?? 0.0;
    if (amount <= 0) {
      print('❌ Invalid amount! Using default 1.0 mg');
    }
    
    final frequencyInput = _getInput('Frequency per day: ');
    final frequency = int.tryParse(frequencyInput) ?? 1;
    if (frequency <= 0) {
      print('❌ Invalid frequency! Using default 1x per day');
    }
    
    final durationInput = _getInput('Duration (days): ');
    final duration = int.tryParse(durationInput) ?? 7;
    if (duration <= 0) {
      print('❌ Invalid duration! Using default 7 days');
    }
    
    final instructions = _getInput('Instructions: ');
    
    print('\nAdding medication with details:');
    print('Name: $name');
    print('Strength: ${strength}mg');
    print('Form: $form');
    print('Dose Amount: ${amount}mg');
    print('Frequency: ${frequency}x per day');
    print('Duration: $duration days');
    print('Instructions: $instructions');
    
    final confirm = _getInput('\nConfirm adding this medication? (y/n): ');
    if (confirm.toLowerCase() != 'y') {
      print('Medication addition cancelled.');
      return;
    }
    
    final success = _prescriptionService.addMedicationToPrescription(
      prescriptionId, name, strength, form, amount, frequency, duration, instructions
    );
    
    if (success) {
      print('✅ Medication added successfully!');
      
      // Verify the medication was actually added
      final updatedPrescription = _prescriptionService.getPrescription(prescriptionId);
      if (updatedPrescription != null && updatedPrescription.medications.isNotEmpty) {
        final lastMed = updatedPrescription.medications.last;
        print('✅ Verified: ${lastMed.name} added to prescription');
      }
    } else {
      print('❌ Failed to add medication');
    }
  }

  void _cancelPrescription(String prescriptionId) {
    final success = _prescriptionService.cancelPrescription(prescriptionId);
    if (success) {
      print('✅ Prescription cancelled!');
    } else {
      print('❌ Failed to cancel prescription');
    }
  }

  void _manageRenewals() {
    final renewals = _medicationService.getPendingRenewals();
    
    if (renewals.isEmpty) {
      print('\nNo pending renewals.');
      return;
    }
    
    print('\n--- Pending Renewals ---');
    for (final r in renewals) {
      final patient = _authService.getPatient(r.patientId);
      print('${r.id} - Patient: ${patient?.name} - Prescription: ${r.prescriptionId}');
    }
    
    final renewalId = _getInput('\nEnter Renewal ID: ');
    
    if (!_medicationService.renewalExists(renewalId)) {
      print('Renewal not found!');
      return;
    }
    
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
    
    final patientId = _getInput('\nEnter Patient ID to view history (or press Enter to go back): ');
    if (patientId.isEmpty) return;
    
    final patient = _authService.getPatient(patientId);
    if (patient == null) {
      print('Patient not found!');
      return;
    }
    
    _viewPatientHistory(patient);
  }

  void _viewPatientHistory(Patient patient) {
    final prescriptions = _prescriptionService.getPatientPrescriptionHistory(patient.id);
    
    print('\n--- Prescription History for ${patient.name} ---');
    if (prescriptions.isEmpty) {
      print('No prescription history.');
      return;
    }
    
    for (final p in prescriptions) {
      print('${p.id} - ${p.status} - ${p.dateIssued}');
      for (final med in p.medications) {
        print('  💊 ${med.name} ${med.strength}mg');
      }
    }
  }

  String _getInput(String prompt) {
    stdout.write('$prompt ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}