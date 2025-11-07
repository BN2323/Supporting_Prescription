import 'package:supporting_prescription/domain/entities/dose_intake.dart';

class DoseIntakeMapper {
  static Map<String, dynamic> toJson(DoseIntake dose) {
    return {
      'id': dose.id,
      'medicationId': dose.medicationId,
      'patientId': dose.patientId,
      'isTaken': dose.isTaken,
      'scheduledTime': dose.scheduledTime.toIso8601String(),
    };
  }
  
  static DoseIntake fromJson(Map<String, dynamic> json) {
    return DoseIntake(
      id: json['id'],
      medicationId: json['medicationId'],
      patientId: json['patientId'],
      isTaken: json['isTaken'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
    );
  }
}