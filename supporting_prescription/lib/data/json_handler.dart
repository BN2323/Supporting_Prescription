import 'dart:convert';
import 'dart:io';
import '../domain/entities/dose_intake.dart';
import '../domain/entities/prescription.dart';
import '../domain/entities/renewal_request.dart';
import '../domain/entities/user.dart';
import './mappers/user_mapper.dart';
import './mappers/prescription_mapper.dart';
import './mappers/dose_intake_mapper.dart';
import './mappers/renewal_mapper.dart';

class JsonHandler {
  static const String _dataDir = 'data';
  
  static Map<String, dynamic> _loadRaw(String fileName) {
    try {
      final file = File('$_dataDir/$fileName.json');
      if (!file.existsSync()) return {};
      
      final content = file.readAsStringSync();
      if (content.trim().isEmpty) return {};
      
      return jsonDecode(content);
    } catch (e) {
      return {};
    }
  }
  
  static void _saveRaw(String fileName, dynamic data) {
    try {
      Directory(_dataDir).createSync(recursive: true);
      final file = File('$_dataDir/$fileName.json');
      file.writeAsStringSync(jsonEncode(data));
    } catch (e) {
      print('Error saving $fileName: $e');
    }
  }
  
  static List<User> loadUsers() {
    final data = _loadRaw('users');
    return (data['users'] ?? []).map<User>((json) => UserMapper.fromJson(json)).toList();
  }
  
  static void saveUsers(List<User> users) {
    _saveRaw('users', {
      'users': users.map((u) => UserMapper.toJson(u)).toList()
    });
  }
  
  static List<Prescription> loadPrescriptions() {
    final data = _loadRaw('prescriptions');
    return (data['prescriptions'] ?? []).map<Prescription>((json) => PrescriptionMapper.fromJson(json)).toList();
  }
  
  static void savePrescriptions(List<Prescription> prescriptions) {
    _saveRaw('prescriptions', {
      'prescriptions': prescriptions.map((p) => PrescriptionMapper.toJson(p)).toList()
    });
  }
  
  static List<DoseIntake> loadDoses() {
    final data = _loadRaw('doses');
    return (data['doses'] ?? []).map<DoseIntake>((json) => DoseIntakeMapper.fromJson(json)).toList();
  }
  
  static void saveDoses(List<DoseIntake> doses) {
    _saveRaw('doses', {
      'doses': doses.map((d) => DoseIntakeMapper.toJson(d)).toList()
    });
  }
  
  static List<RenewalRequest> loadRenewals() {
    final data = _loadRaw('renewals');
    return (data['renewals'] ?? []).map<RenewalRequest>((json) => RenewalMapper.fromJson(json)).toList();
  }
  
  static void saveRenewals(List<RenewalRequest> renewals) {
    _saveRaw('renewals', {
      'renewals': renewals.map((r) => RenewalMapper.toJson(r)).toList()
    });
  }
  
  static String getNextId(String entityType) {
    final prefix = _getPrefix(entityType);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix$timestamp';
  }
  
  static String _getPrefix(String entityType) {
    switch (entityType) {
      case 'doctor': return 'DOC';
      case 'patient': return 'PAT';
      case 'pharmacist': return 'PHA';
      case 'prescription': return 'RX';
      case 'medication': return 'MED';
      case 'renewal': return 'REN';
      case 'dose': return 'DOSE';
      default: return 'ID';
    }
  }
}