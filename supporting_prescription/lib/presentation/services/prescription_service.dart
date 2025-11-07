import '../../data/json_handler.dart';
import '../../domain/entities/dose.dart';
import '../../domain/entities/medication_item.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/enums/medication_form.dart';
import '../../domain/enums/prescription_status.dart';

class PrescriptionService {
  Prescription createPrescription(String doctorId, String patientId, String deaNumber) {
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
  }
  
  void addMedicationToPrescription(
    String prescriptionId,
    String name, double strength, MedForm form,
    double amount, int frequency, int duration, String instructions
  ) {
    final prescriptions = JsonHandler.loadPrescriptions();
    final prescription = prescriptions.firstWhere((p) => p.id == prescriptionId);
    
    final dose = Dose(
      doseId: JsonHandler.getNextId('dose'),
      amount: amount,
      frequencyPerDay: frequency,
      durationInDays: duration,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: duration)),
      instructions: instructions,
    );
    
    final medication = Medication(
      id: JsonHandler.getNextId('medication'),
      name: name,
      strength: strength,
      form: form,
      dose: dose,
    );
    
    prescription.addMedication(medication);
    JsonHandler.savePrescriptions(prescriptions);
  }
  
  void cancelPrescription(String id) {
    final prescriptions = JsonHandler.loadPrescriptions();
    final prescription = prescriptions.firstWhere((p) => p.id == id);
    prescription.cancel();
    JsonHandler.savePrescriptions(prescriptions);
  }
  
  void dispensePrescription(String id) {
    final prescriptions = JsonHandler.loadPrescriptions();
    final prescription = prescriptions.firstWhere((p) => p.id == id);
    prescription.dispense();
    JsonHandler.savePrescriptions(prescriptions);
  }
  
  List<Prescription> getPrescriptionsByPatient(String patientId) {
    final prescriptions = JsonHandler.loadPrescriptions();
    return prescriptions.where((p) => p.patientId == patientId).toList();
  }
  
  List<Prescription> getPrescriptionsByDoctor(String doctorId) {
    final prescriptions = JsonHandler.loadPrescriptions();
    return prescriptions.where((p) => p.doctorId == doctorId).toList();
  }
  
  List<Prescription> getPrescriptionsByStatus(PrescriptionStatus status) {
    final prescriptions = JsonHandler.loadPrescriptions();
    return prescriptions.where((p) => p.status == status).toList();
  }
  
  Prescription getPrescription(String id) {
    final prescriptions = JsonHandler.loadPrescriptions();
    return prescriptions.firstWhere((p) => p.id == id);
  }

  bool prescriptionExists(String prescriptionId) {
    final prescriptions = JsonHandler.loadPrescriptions();
    return prescriptions.any((p) => p.id == prescriptionId);
  }

  List<Prescription> getAllPrescriptions() {
    return JsonHandler.loadPrescriptions();
  }
}