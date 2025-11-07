import 'package:supporting_prescription/data/json_handler.dart';
import 'package:supporting_prescription/domain/entities/dose_intake.dart';
import 'package:supporting_prescription/domain/enums/renewal_status.dart';
import 'package:supporting_prescription/presentation/services/medication_service.dart';
import 'package:supporting_prescription/presentation/services/prescription_service.dart';
import 'package:test/test.dart';
import 'test_help.dart';
void main() {
  group('MedicationService Tests', () {
    late MedicationService medicationService;
    late PrescriptionService prescriptionService;

    setUp(() {
      resetTestData();
      initializeTestData();
      medicationService = MedicationService();
      prescriptionService = PrescriptionService();
    });

    test('Test Mark Dose as Taken - Success', () {
      // Create a test dose and save it using JsonHandler
      final dose = DoseIntake(
        id: 'TEST_DOSE_001',
        scheduledTime: DateTime.now(),
        isTaken: false,
      );

      JsonHandler.saveDoses([dose]);

      // Mark as taken using the actual service method
      final success = medicationService.markDoseAsTaken('TEST_DOSE_001');
      expect(success, true);

      // Verify dose is marked as taken by loading directly from JsonHandler
      final doses = JsonHandler.loadDoses();
      final takenDose = doses.firstWhere((d) => d.id == 'TEST_DOSE_001');
      expect(takenDose.isTaken, true);
    });

    test('Test Mark Dose as Taken - Already Taken', () {
      // Create a dose that's already taken
      final dose = DoseIntake(
        id: 'TEST_DOSE_002',
        scheduledTime: DateTime.now(),
        isTaken: true, // Already taken
      );

      JsonHandler.saveDoses([dose]);

      // Try to mark as taken again
      final success = medicationService.markDoseAsTaken('TEST_DOSE_002');
      expect(success, false); // Should return false since it was already taken
    });

    test('Test Mark Dose as Taken - Non-Existent Dose', () {
      // Try to mark a dose that doesn't exist
      final success = medicationService.markDoseAsTaken('NON_EXISTENT_DOSE');
      expect(success, false);
    });

    test('Test Request Renewal - Success', () {
      // Create a prescription first
      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      expect(prescription, isNotNull);

      // Request renewal
      final success = medicationService.requestRenewal('PAT_000001', prescription!.id);
      expect(success, true);

      // Verify renewal was created
      final renewals = medicationService.getRenewalRequests('PAT_000001');
      expect(renewals.length, 1);
      expect(renewals[0].prescriptionId, prescription.id);
      expect(renewals[0].status, RenewalStatus.pending);
    });

    test('Test Request Renewal - Duplicate', () {
      // Create a prescription
      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      // Request renewal first time
      medicationService.requestRenewal('PAT_000001', prescription!.id);
      
      // Try to request same renewal again
      final success = medicationService.requestRenewal('PAT_000001', prescription.id);
      expect(success, false); // Should fail due to duplicate
    });

    test('Test Process Renewal - Approve', () {
      // Create prescription and renewal
      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      medicationService.requestRenewal('PAT_000001', prescription!.id);
      
      final renewals = medicationService.getRenewalRequests('PAT_000001');
      final renewalId = renewals[0].id;

      // Approve renewal
      final success = medicationService.processRenewal(renewalId, true, 'Approved for 30 more days');
      expect(success, true);

      // Verify renewal status
      final updatedRenewals = medicationService.getRenewalRequests('PAT_000001');
      expect(updatedRenewals[0].status, RenewalStatus.approved);
      expect(updatedRenewals[0].doctorNote, 'Approved for 30 more days');
    });

    test('Test Process Renewal - Deny', () {
      // Create prescription and renewal
      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      medicationService.requestRenewal('PAT_000001', prescription!.id);
      
      final renewals = medicationService.getRenewalRequests('PAT_000001');
      final renewalId = renewals[0].id;

      // Deny renewal
      final success = medicationService.processRenewal(renewalId, false, 'Patient needs follow-up');
      expect(success, true);

      // Verify renewal status
      final updatedRenewals = medicationService.getRenewalRequests('PAT_000001');
      expect(updatedRenewals[0].status, RenewalStatus.denied);
      expect(updatedRenewals[0].doctorNote, 'Patient needs follow-up');
    });

    test('Test Process Renewal - Non-Existent', () {
      // Try to process a renewal that doesn't exist
      final success = medicationService.processRenewal('NON_EXISTENT_RENEWAL', true, 'Test note');
      expect(success, false);
    });

    test('Test Get Today\'s Doses', () {
      final now = DateTime.now();
      
      // Create doses for today and other days
      final todayDose1 = DoseIntake(
        id: 'DOSE_TODAY_1',
        scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
        isTaken: false,
      );

      final todayDose2 = DoseIntake(
        id: 'DOSE_TODAY_2',
        scheduledTime: DateTime(now.year, now.month, now.day, 20, 0),
        isTaken: true,
      );

      final tomorrowDose = DoseIntake(
        id: 'DOSE_TOMORROW',
        scheduledTime: now.add(Duration(days: 1)),
        isTaken: false,
      );

      JsonHandler.saveDoses([todayDose1, todayDose2, tomorrowDose]);

      // Since DoseIntake doesn't have patientId, this returns ALL today's doses
      final todayDoses = medicationService.getTodayDoses('PAT_000001');
      expect(todayDoses.length, 2);
      expect(todayDoses.any((d) => d.id == 'DOSE_TODAY_1'), true);
      expect(todayDoses.any((d) => d.id == 'DOSE_TODAY_2'), true);
      expect(todayDoses.any((d) => d.id == 'DOSE_TOMORROW'), false);
    });

    test('Test Get Renewal Requests', () {
      // Create renewal requests for different patients
      final prescription1 = prescriptionService.createPrescription('DOC_000001', 'PAT_000001', 'DEA1111111');
      final prescription2 = prescriptionService.createPrescription('DOC_000001', 'PAT_000002', 'DEA2222222');

      medicationService.requestRenewal('PAT_000001', prescription1!.id);
      medicationService.requestRenewal('PAT_000002', prescription2!.id);

      // Get renewals for specific patient
      final patient1Renewals = medicationService.getRenewalRequests('PAT_000001');
      expect(patient1Renewals.length, 1);
      expect(patient1Renewals[0].patientId, 'PAT_000001');

      final patient2Renewals = medicationService.getRenewalRequests('PAT_000002');
      expect(patient2Renewals.length, 1);
      expect(patient2Renewals[0].patientId, 'PAT_000002');
    });

    test('Test Get Pending Renewals', () {
      // Create multiple renewals with different statuses
      final prescription1 = prescriptionService.createPrescription('DOC_000001', 'PAT_000001', 'DEA1111111');
      final prescription2 = prescriptionService.createPrescription('DOC_000001', 'PAT_000002', 'DEA2222222');

      medicationService.requestRenewal('PAT_000001', prescription1!.id);
      medicationService.requestRenewal('PAT_000002', prescription2!.id);

      // Approve one renewal
      final renewals = medicationService.getRenewalRequests('PAT_000001');
      medicationService.processRenewal(renewals[0].id, true, 'Approved');

      final pendingRenewals = medicationService.getPendingRenewals();
      expect(pendingRenewals.length, 1); // Only one should be pending
      expect(pendingRenewals[0].patientId, 'PAT_000002');
    });

    test('Test Renewal Exists', () {
      // Create a renewal
      final prescription = prescriptionService.createPrescription('DOC_000001', 'PAT_000001', 'DEA1111111');
      medicationService.requestRenewal('PAT_000001', prescription!.id);
      
      final renewals = medicationService.getRenewalRequests('PAT_000001');
      final renewalId = renewals[0].id;

      // Check if renewal exists
      expect(medicationService.renewalExists(renewalId), true);
      expect(medicationService.renewalExists('NON_EXISTENT'), false);
    });

    test('Test Get Adherence Rate', () {
      // Create test doses (2 taken, 1 not taken = 66.67% adherence)
      final takenDose1 = DoseIntake(id: 'DOSE_1', scheduledTime: DateTime.now(), isTaken: true);
      final takenDose2 = DoseIntake(id: 'DOSE_2', scheduledTime: DateTime.now(), isTaken: true);
      final notTakenDose = DoseIntake(id: 'DOSE_3', scheduledTime: DateTime.now(), isTaken: false);

      JsonHandler.saveDoses([takenDose1, takenDose2, notTakenDose]);

      final adherenceRate = medicationService.getAdherenceRate('PAT_000001');
      expect(adherenceRate, closeTo(66.67, 0.01)); // 2/3 = 66.67%
    });

    test('Test Get Adherence Rate - No Doses', () {
      // Clear any existing doses
      JsonHandler.saveDoses([]);
      
      final adherenceRate = medicationService.getAdherenceRate('PAT_000001');
      expect(adherenceRate, 0.0);
    });
  });
}