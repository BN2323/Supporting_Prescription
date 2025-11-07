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

    // ... other passing tests ...

    test('Test Process Renewal - Approve', () {
      // Create prescription first
      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      expect(prescription, isNotNull);

      // Request renewal
      final renewalSuccess = medicationService.requestRenewal('PAT_000001', prescription!.id);
      expect(renewalSuccess, true);

      // Get the renewal ID that was created
      final renewalsBefore = medicationService.getRenewalRequests('PAT_000001');
      expect(renewalsBefore.length, 1);
      final renewalId = renewalsBefore[0].id;

      // Approve renewal
      final approveSuccess = medicationService.processRenewal(renewalId, true, 'Approved for 30 more days');
      expect(approveSuccess, true);

      // Verify renewal status by reloading from JSON
      final renewalsAfter = JsonHandler.loadRenewals();
      final updatedRenewal = renewalsAfter.firstWhere((r) => r.id == renewalId);
      expect(updatedRenewal.status, RenewalStatus.approved);
      expect(updatedRenewal.doctorNote, 'Approved for 30 more days');
    });

    test('Test Process Renewal - Deny', () {
      // Create prescription first
      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      expect(prescription, isNotNull);

      // Request renewal
      final renewalSuccess = medicationService.requestRenewal('PAT_000001', prescription!.id);
      expect(renewalSuccess, true);

      // Get the renewal ID that was created
      final renewalsBefore = medicationService.getRenewalRequests('PAT_000001');
      expect(renewalsBefore.length, 1);
      final renewalId = renewalsBefore[0].id;

      // Deny renewal
      final denySuccess = medicationService.processRenewal(renewalId, false, 'Patient needs follow-up');
      expect(denySuccess, true);

      // Verify renewal status by reloading from JSON
      final renewalsAfter = JsonHandler.loadRenewals();
      final updatedRenewal = renewalsAfter.firstWhere((r) => r.id == renewalId);
      expect(updatedRenewal.status, RenewalStatus.denied);
      expect(updatedRenewal.doctorNote, 'Patient needs follow-up');
    });

    test('Test Get Today\'s Doses - Current Implementation', () {
      final now = DateTime.now();
      
      // Create doses for today - current implementation returns all today's doses
      final todayDose1 = DoseIntake(
        id: 'DOSE_1',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
        isTaken: false,
      );

      final todayDose2 = DoseIntake(
        id: 'DOSE_2',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: DateTime(now.year, now.month, now.day, 20, 0),
        isTaken: true,
      );

      // Different day dose
      final yesterdayDose = DoseIntake(
        id: 'DOSE_3',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: DateTime(now.year, now.month, now.day - 1, 10, 0),
        isTaken: false,
      );

      JsonHandler.saveDoses([todayDose1, todayDose2, yesterdayDose]);

      // Current implementation returns all today's doses regardless of patientId
      final todayDoses = medicationService.getTodayDoses('PAT_000001');
      
      // Should return 2 doses (both from today)
      expect(todayDoses.length, 2);
    });

    test('Test Get Adherence Rate - Current Implementation', () {
      // Create doses - current implementation calculates for all doses
      final takenDose = DoseIntake(
        id: 'DOSE_1',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: DateTime.now(),
        isTaken: true,
      );

      final notTakenDose = DoseIntake(
        id: 'DOSE_2',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: DateTime.now(),
        isTaken: false,
      );

      final otherDose = DoseIntake(
        id: 'DOSE_3',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: DateTime.now(),
        isTaken: true,
      );

      JsonHandler.saveDoses([takenDose, notTakenDose, otherDose]);

      // Current implementation calculates adherence for all doses
      final adherenceRate = medicationService.getAdherenceRate('PAT_000001');
      // 2 out of 3 doses taken = 66.67%
      expect(adherenceRate, closeTo(66.67, 0.01));
    });

    test('Test Get Adherence Rate - No Doses', () {
      // No doses in the system
      JsonHandler.saveDoses([]);

      final adherenceRate = medicationService.getAdherenceRate('PAT_000001');
      expect(adherenceRate, 0.0);
    });

    test('Test Get Dose History - Current Implementation', () {
      final now = DateTime.now();
      
      final recentDose = DoseIntake(
        id: 'DOSE_1',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: now.subtract(Duration(days: 1)),
        isTaken: true,
      );

      final oldDose = DoseIntake(
        id: 'DOSE_2',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: now.subtract(Duration(days: 10)),
        isTaken: false,
      );

      JsonHandler.saveDoses([recentDose, oldDose]);

      // Current implementation returns all doses sorted by time
      final history = medicationService.getDoseHistory('PAT_000001');
      expect(history.length, 2);
      // Should be sorted by time (newest first)
      expect(history[0].scheduledTime.isAfter(history[1].scheduledTime), true);
    });

    test('Test Get Upcoming Doses - Current Implementation', () {
      final now = DateTime.now();
      
      final upcomingDose = DoseIntake(
        id: 'DOSE_1',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: now.add(Duration(hours: 2)),
        isTaken: false,
      );

      final pastDose = DoseIntake(
        id: 'DOSE_2',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: now.subtract(Duration(hours: 2)),
        isTaken: false,
      );

      final takenDose = DoseIntake(
        id: 'DOSE_3',
        patientId: 'PAT_000001', // Add required patientId
        medicationId: 'MED_000001', // Add required medicationId
        scheduledTime: now.add(Duration(hours: 4)),
        isTaken: true,
      );

      JsonHandler.saveDoses([upcomingDose, pastDose, takenDose]);

      // Current implementation returns upcoming, not-taken doses
      final upcomingDoses = medicationService.getUpcomingDoses('PAT_000001', daysAhead: 7);
      expect(upcomingDoses.length, 1);
      expect(upcomingDoses[0].id, 'DOSE_1');
      expect(upcomingDoses[0].isTaken, false);
    });
  });
}