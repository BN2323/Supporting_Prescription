// renewal_mapper.dart
import '../../domain/entities/renewal_request.dart';
import '../../domain/enums/renewal_status.dart';

class RenewalMapper {
  static Map<String, dynamic> toJson(RenewalRequest renewal) {
    return {
      'id': renewal.id,
      'patientId': renewal.patientId,
      'prescriptionId': renewal.prescriptionId,
      'requestedDate': renewal.requestedDate.toIso8601String(),
      'status': renewal.status.name,
      'doctorNote': renewal.doctorNote,
    };
  }
  
  static RenewalRequest fromJson(Map<String, dynamic> json) {
    return RenewalRequest(
      id: json['id'],
      patientId: json['patientId'],
      prescriptionId: json['prescriptionId'],
      status: RenewalStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }
}