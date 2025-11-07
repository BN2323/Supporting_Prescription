import 'package:supporting_prescription/domain/entities/doctor.dart';
import 'package:supporting_prescription/domain/entities/patient.dart';
import 'package:supporting_prescription/domain/enums/sex.dart';
import 'package:supporting_prescription/presentation/services/auth_service.dart';
import 'package:test/test.dart';
import 'test_help.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      resetTestData();
      initializeTestData();
      authService = AuthService();
    });

    test('Test User Registration and Login', () {
      final patient = Patient(
        id: 'PAT_000001',
        name: 'Test User',
        phone: '555-1234',
        password: 'password123',
        address: 'Test Address',
        dob: DateTime(1990, 1, 1),
        sex: Sex.male,
      );

      // Register user
      authService.registerUser(patient);

      // Test successful login
      expect(authService.login('555-1234', 'password123'), true);
      expect(authService.currentUser?.name, 'Test User');
      expect(authService.currentUser?.phone, '555-1234');
    });

    test('Test Failed Login', () {
      final patient = Patient(
        id: 'PAT_000001',
        name: 'Test User',
        phone: '555-1234',
        password: 'password123',
        address: 'Test Address',
        dob: DateTime(1990, 1, 1),
        sex: Sex.male,
      );

      authService.registerUser(patient);

      // Test wrong password
      expect(authService.login('555-1234', 'wrongpassword'), false);
      
      // Test wrong phone
      expect(authService.login('555-9999', 'password123'), false);
    });

    test('Test Duplicate Phone Registration', () {
      final patient1 = Patient(
        id: 'PAT_000001',
        name: 'User One',
        phone: '555-1234',
        password: 'pass1',
        address: 'Address 1',
        dob: DateTime(1990, 1, 1),
        sex: Sex.male,
      );

      final patient2 = Patient(
        id: 'PAT_000002',
        name: 'User Two',
        phone: '555-1234', // Same phone
        password: 'pass2',
        address: 'Address 2',
        dob: DateTime(1990, 1, 1),
        sex: Sex.male,
      );

      authService.registerUser(patient1);
      
      // Should throw exception for duplicate phone
      expect(() => authService.registerUser(patient2), throwsException);
    });

    test('Test Get Patients', () {
      final patient1 = Patient(
        id: 'PAT_000001',
        name: 'Patient One',
        phone: '555-0001',
        password: 'pass1',
        address: 'Address 1',
        dob: DateTime(1990, 1, 1),
        sex: Sex.male,
      );

      final patient2 = Patient(
        id: 'PAT_000002',
        name: 'Patient Two',
        phone: '555-0002',
        password: 'pass2',
        address: 'Address 2',
        dob: DateTime(1990, 1, 1),
        sex: Sex.female,
      );

      final doctor = Doctor(
        id: 'DOC_000001',
        name: 'Doctor One',
        phone: '555-0003',
        password: 'docpass',
        licenseNumber: 'DOC123',
        specialization: 'Cardiology',
      );

      authService.registerUser(patient1);
      authService.registerUser(patient2);
      authService.registerUser(doctor);

      final patients = authService.getPatients();
      
      // Should only return patients, not doctors
      expect(patients.length, 2);
      expect(patients.any((p) => p.name == 'Patient One'), true);
      expect(patients.any((p) => p.name == 'Patient Two'), true);
      expect(patients.any((p) => p.name == 'Doctor One'), false);
    });

    test('Test Logout', () {
      final patient = Patient(
        id: 'PAT_000001',
        name: 'Test User',
        phone: '555-1234',
        password: 'password123',
        address: 'Test Address',
        dob: DateTime(1990, 1, 1),
        sex: Sex.male,
      );

      authService.registerUser(patient);
      authService.login('555-1234', 'password123');
      
      expect(authService.currentUser, isNotNull);
      
      authService.logout();
      
      expect(authService.currentUser, isNull);
    });
  });
}