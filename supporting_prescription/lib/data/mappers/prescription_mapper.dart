// prescription_mapper.dart
import '../../domain/entities/prescription.dart';
import '../../domain/enums/prescription_status.dart';
import './medication_mapper.dart';

class PrescriptionMapper {
  static Map<String, dynamic> toJson(Prescription prescription) {
    return {
      'id': prescription.id,
      'doctorId': prescription.doctorId,
      'patientId': prescription.patientId,
      'dateIssued': prescription.dateIssued.toIso8601String(),
      'deaNumber': prescription.deaNumber,
      'status': prescription.status.name,
      'medications': prescription.medications.map((m) => MedicationMapper.toJson(m)).toList(),
    };
  }
  
  static Prescription fromJson(Map<String, dynamic> json) {
    final prescription = Prescription(
      id: json['id'],
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      deaNumber: json['deaNumber'],
      status: PrescriptionStatus.values.firstWhere((e) => e.name == json['status']), 
    );
    
    final medications = (json['medications'] as List)
        .map((m) => MedicationMapper.fromJson(m))
        .toList();
    
    prescription.medications.addAll(medications);
    return prescription;
  }
}