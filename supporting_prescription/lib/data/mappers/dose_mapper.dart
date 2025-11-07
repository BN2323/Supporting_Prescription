// dose_mapper.dart
import '../../domain/entities/dose.dart';

class DoseMapper {
  static Map<String, dynamic> toJson(Dose dose) {
    return {
      'doseId': dose.doseId,
      'amount': dose.amount,
      'frequencyPerDay': dose.frequencyPerDay,
      'durationInDays': dose.durationInDays,
      'startDate': dose.startDate.toIso8601String(),
      'endDate': dose.endDate.toIso8601String(),
      'instructions': dose.instructions,
    };
  }
  
  static Dose fromJson(Map<String, dynamic> json) {
    return Dose(
      doseId: json['doseId'],
      amount: json['amount'],
      frequencyPerDay: json['frequencyPerDay'],
      durationInDays: json['durationInDays'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      instructions: json['instructions'],
    );
  }
}