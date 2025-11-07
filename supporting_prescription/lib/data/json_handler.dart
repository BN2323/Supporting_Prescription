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
  static const String _sequenceFile = '$_dataDir/sequences.json';
  
  static final Map<String, int> _sequences = {};
  static bool _sequencesInitialized = false;
  
  static void _initializeSequences() {
    if (_sequencesInitialized) return;
    
    try {
      final file = File(_sequenceFile);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.trim().isNotEmpty) {
          final data = jsonDecode(content);
          _sequences.addAll(Map<String, int>.from(data));
        }
      }
    } catch (e) {
      print('Warning: Error loading sequences: $e');
    }
    
    // Initialize default sequences
    _sequences.putIfAbsent('doctor', () => 1);
    _sequences.putIfAbsent('patient', () => 1);
    _sequences.putIfAbsent('pharmacist', () => 1);
    _sequences.putIfAbsent('prescription', () => 1);
    _sequences.putIfAbsent('medication', () => 1);
    _sequences.putIfAbsent('renewal', () => 1);
    _sequences.putIfAbsent('dose', () => 1);
    
    _saveSequences();
    _sequencesInitialized = true;
  }
  
  static void _saveSequences() {
    try {
      Directory(_dataDir).createSync(recursive: true);
      final file = File(_sequenceFile);
      file.writeAsStringSync(jsonEncode(_sequences));
    } catch (e) {
      print('Error saving sequences: $e');
    }
  }
  
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
    _initializeSequences();
    
    final prefix = _getPrefix(entityType);
    final sequence = _sequences[entityType] ?? 1;
    
    // Clean sequential ID: PREFIX_SEQUENCE
    final id = '${prefix}_${sequence.toString().padLeft(6, '0')}';
    
    // Increment sequence for next call
    _sequences[entityType] = sequence + 1;
    _saveSequences();
    
    return id;
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
  
  // Method to check current sequences (useful for debugging)
  static Map<String, int> getCurrentSequences() {
    _initializeSequences();
    return Map.from(_sequences);
  }
}