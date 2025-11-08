import 'package:supporting_prescription/domain/entities/doctor.dart';
import 'package:supporting_prescription/domain/entities/patient.dart';
import 'package:supporting_prescription/domain/enums/medication_form.dart';
import 'package:supporting_prescription/domain/enums/prescription_status.dart';
import 'package:supporting_prescription/domain/enums/sex.dart';
import 'package:supporting_prescription/presentation/services/auth_service.dart';
import 'package:supporting_prescription/presentation/services/prescription_service.dart';
import 'package:test/test.dart';
import 'test_help.dart';

void main() {
  group('PrescriptionService Tests', () {
    late PrescriptionService prescriptionService;
    late AuthService authService;

    setUp(() {
      resetTestData();
      initializeTestData();
      prescriptionService = PrescriptionService();
      authService = AuthService();
    });

    test('Test Create Prescription', () {
      final doctor = Doctor(
        id: 'DOC_000001',
        name: 'Test Doctor',
        phone: '555-0001',
        password: 'doc123',
        licenseNumber: 'DOC123',
        specialization: 'Cardiology',
      );

      final patient = Patient(
        id: 'PAT_000001',
        name: 'Test Patient',
        phone: '555-0002',
        password: 'pat123',
        address: 'Test Address',
        dob: DateTime(1990, 1, 1),
        sex: Sex.male,
      );

      authService.registerUser(doctor);
      authService.registerUser(patient);

      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      expect(prescription, isNotNull);
      expect(prescription!.doctorId, 'DOC_000001');
      expect(prescription.patientId, 'PAT_000001');
      expect(prescription.status, PrescriptionStatus.pending);
    });

    test('Test Add Medication to Prescription', () {

      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      expect(prescription, isNotNull);


      final success = prescriptionService.addMedicationToPrescription(
        prescription!.id,
        'Test Medication',
        500.0,
        MedForm.tablet,
        500.0,
        2,
        30,
        'Take with food',
      );

      expect(success, true);

 
      final loadedPrescription = prescriptionService.getPrescription(prescription.id);
      expect(loadedPrescription, isNotNull);
      expect(loadedPrescription!.medications.length, 1);
      expect(loadedPrescription.medications[0].name, 'Test Medication');
      expect(loadedPrescription.medications[0].strength, 500.0);
    });

    test('Test Cancel Prescription', () {
      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      expect(prescription, isNotNull);
      expect(prescription!.status, PrescriptionStatus.pending);

      final success = prescriptionService.cancelPrescription(prescription.id);
      expect(success, true);

      final cancelledPrescription = prescriptionService.getPrescription(prescription.id);
      expect(cancelledPrescription!.status, PrescriptionStatus.cancelled);
    });

    test('Test Dispense Prescription', () {
      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      expect(prescription, isNotNull);
      expect(prescription!.status, PrescriptionStatus.pending);

      final success = prescriptionService.dispensePrescription(prescription.id);
      expect(success, true);

      final dispensedPrescription = prescriptionService.getPrescription(prescription.id);
      expect(dispensedPrescription!.status, PrescriptionStatus.dispensed);
    });

    test('Test Get Prescriptions by Patient', () {

      prescriptionService.createPrescription('DOC_000001', 'PAT_000001', 'DEA1111111');
      prescriptionService.createPrescription('DOC_000002', 'PAT_000001', 'DEA2222222');
      prescriptionService.createPrescription('DOC_000001', 'PAT_000002', 'DEA3333333'); 

      final patientPrescriptions = prescriptionService.getPrescriptionsByPatient('PAT_000001');
      expect(patientPrescriptions.length, 2);
    });

    test('Test Get Prescriptions by Doctor', () {
      prescriptionService.createPrescription('DOC_000001', 'PAT_000001', 'DEA1111111');
      prescriptionService.createPrescription('DOC_000001', 'PAT_000002', 'DEA2222222');
      prescriptionService.createPrescription('DOC_000002', 'PAT_000001', 'DEA3333333');

      final doctorPrescriptions = prescriptionService.getPrescriptionsByDoctor('DOC_000001');
      expect(doctorPrescriptions.length, 2);
    });
  });
}