import '../enums/renewal_status.dart';

class RenewalRequest {
  final String id;
  final String patientId;
  final String prescriptionId;
  final DateTime requestedDate;
  RenewalStatus status;
  String? doctorNote;
  
  RenewalRequest({
    required this.id,
    required this.patientId,
    required this.prescriptionId,
    DateTime? requestedDate,
    this.status = RenewalStatus.pending,
  }): requestedDate = requestedDate ?? DateTime.now();
  
  void approve(String note) {
    status = RenewalStatus.approved;
    doctorNote = note;
  }
  
  void deny(String reason) {
    status = RenewalStatus.denied;
    doctorNote = reason;
  }
}