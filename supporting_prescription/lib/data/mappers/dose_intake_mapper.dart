// dose_intake_mapper.dart
import '../../domain/entities/dose_intake.dart';

class DoseIntakeMapper {
  static Map<String, dynamic> toJson(DoseIntake dose) {
    return {
      'id': dose.id,
      'isTaken': dose.isTaken,
      'scheduledTime': dose.scheduledTime.toIso8601String(),
    };
  }
  
  static DoseIntake fromJson(Map<String, dynamic> json) {
    return DoseIntake(
      id: json['id'],
      isTaken: json['isTaken'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
    );
  }
} 