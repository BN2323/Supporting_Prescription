import '../enums/prescription_status.dart';
import 'medication_item.dart';

class Prescription {
  final String id;
  final String doctorId;
  final String patientId;
  final DateTime dateIssued;
  final String deaNumber;
  PrescriptionStatus status;
  final List<Medication> medications;
  
  Prescription({required this.id, required this.doctorId, required this.patientId, 
               DateTime? dateIssued, required this.deaNumber, this.status = PrescriptionStatus.pending})
      : this.dateIssued = dateIssued ?? DateTime.now(), medications = [];
  
  void addMedication(Medication med) => medications.add(med);
  
  void cancel() => status = PrescriptionStatus.cancelled;
  
  void dispense() => status = PrescriptionStatus.dispensed;
  
  bool get isExpired => dateIssued.add(Duration(days: 30)).isBefore(DateTime.now());
}