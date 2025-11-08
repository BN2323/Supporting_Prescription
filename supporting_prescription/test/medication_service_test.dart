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



    test('Test Process Renewal - Approve', () {

      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      expect(prescription, isNotNull);


      final renewalSuccess = medicationService.requestRenewal('PAT_000001', prescription!.id);
      expect(renewalSuccess, true);


      final renewalsBefore = medicationService.getRenewalRequests('PAT_000001');
      expect(renewalsBefore.length, 1);
      final renewalId = renewalsBefore[0].id;


      final approveSuccess = medicationService.processRenewal(renewalId, true, 'Approved for 30 more days');
      expect(approveSuccess, true);


      final renewalsAfter = JsonHandler.loadRenewals();
      final updatedRenewal = renewalsAfter.firstWhere((r) => r.id == renewalId);
      expect(updatedRenewal.status, RenewalStatus.approved);
      expect(updatedRenewal.doctorNote, 'Approved for 30 more days');
    });

    test('Test Process Renewal - Deny', () {

      final prescription = prescriptionService.createPrescription(
        'DOC_000001',
        'PAT_000001',
        'DEA1234567',
      );

      expect(prescription, isNotNull);


      final renewalSuccess = medicationService.requestRenewal('PAT_000001', prescription!.id);
      expect(renewalSuccess, true);


      final renewalsBefore = medicationService.getRenewalRequests('PAT_000001');
      expect(renewalsBefore.length, 1);
      final renewalId = renewalsBefore[0].id;


      final denySuccess = medicationService.processRenewal(renewalId, false, 'Patient needs follow-up');
      expect(denySuccess, true);


      final renewalsAfter = JsonHandler.loadRenewals();
      final updatedRenewal = renewalsAfter.firstWhere((r) => r.id == renewalId);
      expect(updatedRenewal.status, RenewalStatus.denied);
      expect(updatedRenewal.doctorNote, 'Patient needs follow-up');
    });

    test('Test Get Today\'s Doses - Current Implementation', () {
      final now = DateTime.now();
      

      final todayDose1 = DoseIntake(
        id: 'DOSE_1',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
        isTaken: false,
      );

      final todayDose2 = DoseIntake(
        id: 'DOSE_2',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: DateTime(now.year, now.month, now.day, 20, 0),
        isTaken: true,
      );


      final yesterdayDose = DoseIntake(
        id: 'DOSE_3',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: DateTime(now.year, now.month, now.day - 1, 10, 0),
        isTaken: false,
      );

      JsonHandler.saveDoses([todayDose1, todayDose2, yesterdayDose]);


      final todayDoses = medicationService.getTodayDoses('PAT_000001');
      

      expect(todayDoses.length, 2);
    });

    test('Test Get Adherence Rate - Current Implementation', () {

      final takenDose = DoseIntake(
        id: 'DOSE_1',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: DateTime.now(),
        isTaken: true,
      );

      final notTakenDose = DoseIntake(
        id: 'DOSE_2',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: DateTime.now(),
        isTaken: false,
      );

      final otherDose = DoseIntake(
        id: 'DOSE_3',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001', 
        scheduledTime: DateTime.now(),
        isTaken: true,
      );

      JsonHandler.saveDoses([takenDose, notTakenDose, otherDose]);


      final adherenceRate = medicationService.getAdherenceRate('PAT_000001');

      expect(adherenceRate, closeTo(66.67, 0.01));
    });

    test('Test Get Adherence Rate - No Doses', () {

      JsonHandler.saveDoses([]);

      final adherenceRate = medicationService.getAdherenceRate('PAT_000001');
      expect(adherenceRate, 0.0);
    });

    test('Test Get Dose History - Current Implementation', () {
      final now = DateTime.now();
      
      final recentDose = DoseIntake(
        id: 'DOSE_1',
        patientId: 'PAT_000001', 
        medicationId: 'MED_000001',
        scheduledTime: now.subtract(Duration(days: 1)),
        isTaken: true,
      );

      final oldDose = DoseIntake(
        id: 'DOSE_2',
        patientId: 'PAT_000001', 
        medicationId: 'MED_000001',
        scheduledTime: now.subtract(Duration(days: 10)),
        isTaken: false,
      );

      JsonHandler.saveDoses([recentDose, oldDose]);


      final history = medicationService.getDoseHistory('PAT_000001');
      expect(history.length, 2);

      expect(history[0].scheduledTime.isAfter(history[1].scheduledTime), true);
    });

    test('Test Get Upcoming Doses - Current Implementation', () {
      final now = DateTime.now();
      
      final upcomingDose = DoseIntake(
        id: 'DOSE_1',
        patientId: 'PAT_000001', 
        medicationId: 'MED_000001', 
        scheduledTime: now.add(Duration(hours: 2)),
        isTaken: false,
      );

      final pastDose = DoseIntake(
        id: 'DOSE_2',
        patientId: 'PAT_000001', 
        medicationId: 'MED_000001', 
        scheduledTime: now.subtract(Duration(hours: 2)),
        isTaken: false,
      );

      final takenDose = DoseIntake(
        id: 'DOSE_3',
        patientId: 'PAT_000001', 
        medicationId: 'MED_000001', 
        scheduledTime: now.add(Duration(hours: 4)),
        isTaken: true,
      );

      JsonHandler.saveDoses([upcomingDose, pastDose, takenDose]);


      final upcomingDoses = medicationService.getUpcomingDoses('PAT_000001', daysAhead: 7);
      expect(upcomingDoses.length, 1);
      expect(upcomingDoses[0].id, 'DOSE_1');
      expect(upcomingDoses[0].isTaken, false);
    });
  });
}