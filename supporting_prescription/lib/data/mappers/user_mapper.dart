import '../../domain/entities/user.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/pharmacist.dart';
import '../../domain/enums/role.dart';
import '../../domain/enums/sex.dart';

class UserMapper {
  static Map<String, dynamic> toJson(User user) {
    final json = {
      'id': user.id,
      'name': user.name,
      'phone': user.phone,
      'password': user.password,
      'role': user.role.name,
    };
    
    if (user is Doctor) {
      json.addAll({
        'licenseNumber': user.licenseNumber,
        'specialization': user.specialization,
      });
    } else if (user is Patient) {
      json.addAll({
        'address': user.address,
        'dob': user.dob.toIso8601String(),
        'sex': user.sex.name,
      });
    } else if (user is Pharmacist) {
      json.addAll({
        'registrationId': user.registrationId,
        'pharmacyName': user.pharmacyName,
      });
    }
    
    return json;
  }
  
  static User fromJson(Map<String, dynamic> json) {
    // Add null safety
    final roleString = json['role'] as String? ?? 'patient';
    final role = Role.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => Role.patient,
    );
    
    switch (role) {
      case Role.doctor:
        return Doctor(
          id: json['id'] as String? ?? '',
          name: json['name'] as String? ?? '',
          phone: json['phone'] as String? ?? '',
          password: json['password'] as String? ?? '',
          licenseNumber: json['licenseNumber'] as String? ?? '',
          specialization: json['specialization'] as String? ?? '',
        );
      case Role.patient:
        return Patient(
          id: json['id'] as String? ?? '',
          name: json['name'] as String? ?? '',
          phone: json['phone'] as String? ?? '',
          password: json['password'] as String? ?? '',
          address: json['address'] as String? ?? '',
          dob: DateTime.tryParse(json['dob'] as String? ?? '') ?? DateTime(2000),
          sex: Sex.values.firstWhere(
            (e) => e.name == (json['sex'] as String? ?? 'male'),
            orElse: () => Sex.male,
          ),
        );
      case Role.pharmacist:
        return Pharmacist(
          id: json['id'] as String? ?? '',
          name: json['name'] as String? ?? '',
          phone: json['phone'] as String? ?? '',
          password: json['password'] as String? ?? '',
          registrationId: json['registrationId'] as String? ?? '',
          pharmacyName: json['pharmacyName'] as String? ?? '',
        );
      default:
        return User(
          id: json['id'] as String? ?? '',
          name: json['name'] as String? ?? '',
          phone: json['phone'] as String? ?? '',
          password: json['password'] as String? ?? '',
          role: role,
        );
    }
  }
}