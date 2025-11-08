import 'package:supporting_prescription/data/json_handler.dart';
import 'package:supporting_prescription/domain/entities/doctor.dart';
import 'package:supporting_prescription/domain/entities/dose_intake.dart';
import 'package:supporting_prescription/domain/entities/patient.dart';
import 'package:supporting_prescription/domain/entities/prescription.dart';
import 'package:supporting_prescription/domain/entities/renewal_request.dart';
import 'package:supporting_prescription/domain/enums/prescription_status.dart';
import 'package:supporting_prescription/domain/enums/renewal_status.dart';
import 'package:supporting_prescription/domain/enums/role.dart';
import 'package:supporting_prescription/domain/enums/sex.dart';
import 'package:test/test.dart';
import 'test_help.dart';

void main() {
  group('JsonHandler Tests', () {
    setUp(() {
      resetTestData();
      initializeTestData();
    });

    test('Test ID Generation Sequence', () {

      expect(JsonHandler.getNextId('patient'), 'PAT_000001');
      expect(JsonHandler.getNextId('patient'), 'PAT_000002');
      expect(JsonHandler.getNextId('doctor'), 'DOC_000001');
      expect(JsonHandler.getNextId('prescription'), 'RX_000001');
    });

    test('Test User CRUD Operations', () {

      final patient = Patient(
        id: 'PAT_000001',
        name: 'Test Patient',
        phone: '555-0001',
        password: 'test123',
        address: 'Test Address',
        dob: DateTime(1990, 1, 1),
        sex: Sex.male,
      );

      final doctor = Doctor(
        id: 'DOC_000001',
        name: 'Test Doctor',
        phone: '555-0002',
        password: 'doc123',
        licenseNumber: 'TEST123',
        specialization: 'Test Specialty',
      );


      JsonHandler.saveUsers([patient, doctor]);


      final loadedUsers = JsonHandler.loadUsers();
      expect(loadedUsers.length, 2);
      expect(loadedUsers[0].name, 'Test Patient');
      expect(loadedUsers[1].name, 'Test Doctor');
      expect(loadedUsers[0].role, Role.patient);
      expect(loadedUsers[1].role, Role.doctor);
    });

    test('Test Prescription CRUD Operations', () {
      final prescription = Prescription(
        id: 'RX_000001',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'TEST1234567',
        status: PrescriptionStatus.pending,
      );

      JsonHandler.savePrescriptions([prescription]);

      final loadedPrescriptions = JsonHandler.loadPrescriptions();
      expect(loadedPrescriptions.length, 1);
      expect(loadedPrescriptions[0].id, 'RX_000001');
      expect(loadedPrescriptions[0].status, PrescriptionStatus.pending);
    });

    test('Test DoseIntake CRUD Operations', () {
      final dose = DoseIntake(
        id: 'DOSE_000001',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: DateTime(2024, 1, 1, 8, 0),
        isTaken: false,
      );

      JsonHandler.saveDoses([dose]);

      final loadedDoses = JsonHandler.loadDoses();
      expect(loadedDoses.length, 1);
      expect(loadedDoses[0].id, 'DOSE_000001');
      expect(loadedDoses[0].patientId, 'PAT_000001'); 
      expect(loadedDoses[0].medicationId, 'MED_000001'); 
      expect(loadedDoses[0].isTaken, false);
    });

    test('Test RenewalRequest CRUD Operations', () {
      final renewal = RenewalRequest(
        id: 'REN_000001',
        patientId: 'PAT_000001',
        prescriptionId: 'RX_000001',
        status: RenewalStatus.pending,
      );

      JsonHandler.saveRenewals([renewal]);

      final loadedRenewals = JsonHandler.loadRenewals();
      expect(loadedRenewals.length, 1);
      expect(loadedRenewals[0].id, 'REN_000001');
      expect(loadedRenewals[0].status, RenewalStatus.pending);
    });

    test('Test Empty File Handling', () {

      final users = JsonHandler.loadUsers();
      final prescriptions = JsonHandler.loadPrescriptions();
      final doses = JsonHandler.loadDoses();
      final renewals = JsonHandler.loadRenewals();

      expect(users, isEmpty);
      expect(prescriptions, isEmpty);
      expect(doses, isEmpty);
      expect(renewals, isEmpty);
    });

    test('Test Update Operations', () {

      final initialDose = DoseIntake(
        id: 'DOSE_000001',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: DateTime(2024, 1, 1, 8, 0),
        isTaken: false,
      );

      JsonHandler.saveDoses([initialDose]);


      final loadedDoses = JsonHandler.loadDoses();
      final doseToUpdate = loadedDoses.first;
      doseToUpdate.markTaken(); 
      
      JsonHandler.saveDoses(loadedDoses);


      final updatedDoses = JsonHandler.loadDoses();
      expect(updatedDoses[0].isTaken, true);
    });

    test('Test Multiple Items CRUD', () {

      final doses = [
        DoseIntake(
          id: 'DOSE_000001',
          patientId: 'PAT_000001',
          medicationId: 'MED_000001',
          scheduledTime: DateTime(2024, 1, 1, 8, 0),
          isTaken: false,
        ),
        DoseIntake(
          id: 'DOSE_000002',
          patientId: 'PAT_000001',
          medicationId: 'MED_000001',
          scheduledTime: DateTime(2024, 1, 1, 20, 0),
          isTaken: false,
        ),
      ];

      JsonHandler.saveDoses(doses);

      final loadedDoses = JsonHandler.loadDoses();
      expect(loadedDoses.length, 2);
      expect(loadedDoses[0].id, 'DOSE_000001');
      expect(loadedDoses[1].id, 'DOSE_000002');
    });
  });
}