import 'package:supporting_prescription/domain/entities/medication_item.dart';

import '../../data/json_handler.dart';
import '../../domain/entities/dose.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/enums/medication_form.dart';
import '../../domain/enums/prescription_status.dart';

class PrescriptionService {
  Prescription? createPrescription(String doctorId, String patientId, String deaNumber) {
    try {
      final prescriptions = JsonHandler.loadPrescriptions();
      
      final prescription = Prescription(
        id: JsonHandler.getNextId('prescription'),
        doctorId: doctorId,
        patientId: patientId,
        deaNumber: deaNumber,
      );
      
      prescriptions.add(prescription);
      JsonHandler.savePrescriptions(prescriptions);
      return prescription;
    } catch (e) {
      print('Error creating prescription: $e');
      return null;
    }
  }
  
  bool addMedicationToPrescription(
    String prescriptionId,
    String name, 
    double strength, 
    MedForm form,
    double amount, 
    int frequency, 
    int duration, 
    String instructions
  ) {
    try {
      final prescriptions = JsonHandler.loadPrescriptions();
      final prescriptionIndex = prescriptions.indexWhere((p) => p.id == prescriptionId);
      
      if (prescriptionIndex == -1) {
        print('Prescription not found');
        return false;
      }
      
      final prescription = prescriptions[prescriptionIndex];
      
      // Create dose with proper schedule
      final dose = Dose(
        doseId: JsonHandler.getNextId('dose'),
        amount: amount,
        frequencyPerDay: frequency,
        durationInDays: duration,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: duration)),
        instructions: instructions,
      );
      
      // Create medication
      final medication = Medication(
        id: JsonHandler.getNextId('medication'),
        name: name,
        strength: strength,
        form: form,
        dose: dose,
      );
      
      // Add medication to prescription
      prescription.addMedication(medication);
      JsonHandler.savePrescriptions(prescriptions);
      
      // Generate and save dose intake schedule
      _generateDoseSchedule(medication);
      return true;
    } catch (e) {
      print('Error adding medication: $e');
      return false;
    }
  }
  
  void _generateDoseSchedule(Medication medication) {
    try {
      final doses = JsonHandler.loadDoses();
      final schedule = medication.generateSchedule();
      doses.addAll(schedule);
      JsonHandler.saveDoses(doses); 
    } catch (e) {
      print('Error generating dose schedule: $e');
    }
  }
  
  bool cancelPrescription(String id) {
    try {
      final prescriptions = JsonHandler.loadPrescriptions();
      final prescriptionIndex = prescriptions.indexWhere((p) => p.id == id);
      
      if (prescriptionIndex == -1) {
        print('Prescription not found');
        return false;
      }
      
      final prescription = prescriptions[prescriptionIndex];
      prescription.cancel();
      JsonHandler.savePrescriptions(prescriptions);
      return true;
    } catch (e) {
      print('Error cancelling prescription: $e');
      return false;
    }
  }
  
  bool dispensePrescription(String id) {
    try {
      final prescriptions = JsonHandler.loadPrescriptions();
      final prescriptionIndex = prescriptions.indexWhere((p) => p.id == id);
      
      if (prescriptionIndex == -1) {
        print('Prescription not found');
        return false;
      }
      
      final prescription = prescriptions[prescriptionIndex];
      prescription.dispense();
      JsonHandler.savePrescriptions(prescriptions);
      return true;
    } catch (e) {
      print('Error dispensing prescription: $e');
      return false;
    }
  }
  
  List<Prescription> getPrescriptionsByPatient(String patientId) {
    try {
      final prescriptions = JsonHandler.loadPrescriptions();
      return prescriptions.where((p) => p.patientId == patientId).toList();
    } catch (e) {
      print('Error loading patient prescriptions: $e');
      return [];
    }
  }
  
  List<Prescription> getPrescriptionsByDoctor(String doctorId) {
    try {
      final prescriptions = JsonHandler.loadPrescriptions();
      return prescriptions.where((p) => p.doctorId == doctorId).toList();
    } catch (e) {
      print('Error loading doctor prescriptions: $e');
      return [];
    }
  }
  
  List<Prescription> getPrescriptionsByStatus(PrescriptionStatus status) {
    try {
      final prescriptions = JsonHandler.loadPrescriptions();
      return prescriptions.where((p) => p.status == status).toList();
    } catch (e) {
      print('Error loading prescriptions by status: $e');
      return [];
    }
  }
  
  Prescription? getPrescription(String id) {
    try {
      final prescriptions = JsonHandler.loadPrescriptions();
      return prescriptions.firstWhere((p) => p.id == id);
    } catch (e) {
      print('Prescription not found: $e');
      return null;
    }
  }

  bool prescriptionExists(String prescriptionId) {
    final prescriptions = JsonHandler.loadPrescriptions();
    return prescriptions.any((p) => p.id == prescriptionId);
  }

  List<Prescription> getAllPrescriptions() {
    try {
      return JsonHandler.loadPrescriptions();
    } catch (e) {
      print('Error loading all prescriptions: $e');
      return [];
    }
  }
  
  // New method to get patient prescription history
  List<Prescription> getPatientPrescriptionHistory(String patientId) {
    final prescriptions = getPrescriptionsByPatient(patientId);
    return prescriptions..sort((a, b) => b.dateIssued.compareTo(a.dateIssued));
  }
}