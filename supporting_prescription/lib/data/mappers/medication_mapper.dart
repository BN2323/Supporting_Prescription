
import '../../domain/entities/medication_item.dart';
import '../../domain/enums/medication_form.dart';
import './dose_mapper.dart';

class MedicationMapper {
  static Map<String, dynamic> toJson(Medication medication) {
    return {
      'id': medication.id,
      'name': medication.name,
      'strength': medication.strength,
      'form': medication.form.name,
      'dose': DoseMapper.toJson(medication.dose),
    };
  }
  
  static Medication fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      strength: json['strength'],
      form: MedForm.values.firstWhere((e) => e.name == json['form']),
      dose: DoseMapper.fromJson(json['dose']),
    );
  }
}