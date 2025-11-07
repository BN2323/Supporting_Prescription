import 'package:supporting_prescription/data/json_handler.dart';
import 'package:supporting_prescription/domain/entities/dose_intake.dart';
import 'package:supporting_prescription/domain/entities/medication_item.dart';
import 'package:supporting_prescription/domain/entities/prescription.dart';
import 'package:supporting_prescription/domain/enums/medication_form.dart';
import 'package:supporting_prescription/domain/enums/prescription_status.dart';
import 'package:supporting_prescription/presentation/services/reminder_service.dart';
import 'package:test/test.dart';
import 'test_help.dart';

void main() {
  group('ReminderService Tests', () {
    setUp(() {
      resetTestData();
      initializeTestData();
    });

    test('Test CheckReminders - No Upcoming Doses', () {
      // No doses in the system
      JsonHandler.saveDoses([]);
      
      // Capture print output
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
      
      expect(output, isEmpty);
    });

    test('Test CheckReminders - Upcoming Doses in Next Hour', () {
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
      // Create a prescription first
      final prescription = Prescription(
        id: 'RX_000001',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'TEST1234567',
        status: PrescriptionStatus.dispensed,
      );
      
      final medication = Medication(
        id: 'MED_000001',
        name: 'Test Medication',
        strength: 500.0,
        form: MedForm.tablet,
        dose: Dose(
          doseId: 'DOSE_000001',
          amount: 500.0,
          frequencyPerDay: 1,
          durationInDays: 7,
          startDate: now,
          endDate: now.add(Duration(days: 7)),
          instructions: 'Take with food',
        ),
      );
      
      prescription.addMedication(medication);
      JsonHandler.savePrescriptions([prescription]);
      
      // Create upcoming dose
      final upcomingDose = DoseIntake(
        id: 'DOSE_UPCOMING',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: in30Minutes,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([upcomingDose]);
      
      // Capture print output
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
      
      expect(output, contains('🔔 MEDICATION REMINDERS'));
      expect(output, contains('Test Medication 500.0mg'));
      expect(output, contains('READY TO TAKE'));
    });

    test('Test CheckReminders - Doses Outside Next Hour', () {
      final now = DateTime.now();
      final in2Hours = now.add(Duration(hours: 2));
      
      // Create dose outside the 1-hour window
      final futureDose = DoseIntake(
        id: 'DOSE_FUTURE',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: in2Hours,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([futureDose]);
      
      // Capture print output
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
      
      expect(output, isEmpty);
    });

    test('Test CheckReminders - Already Taken Doses', () {
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
      // Create already taken dose
      final takenDose = DoseIntake(
        id: 'DOSE_TAKEN',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: in30Minutes,
        isTaken: true, // Already taken
      );
      
      JsonHandler.saveDoses([takenDose]);
      
      // Capture print output
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
      
      expect(output, isEmpty);
    });

    test('Test CheckReminders - Different Patient ID', () {
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
      // Create dose for different patient
      final otherPatientDose = DoseIntake(
        id: 'DOSE_OTHER',
        patientId: 'PAT_000002', // Different patient
        medicationId: 'MED_000001',
        scheduledTime: in30Minutes,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([otherPatientDose]);
      
      // Capture print output
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
      
      expect(output, isEmpty);
    });

    test('Test ShowMissedDoses - No Missed Doses', () {
      // No doses in the system
      JsonHandler.saveDoses([]);
      
      // Capture print output
      final output = capturePrint(() {
        ReminderService.showMissedDoses('PAT_000001');
      });
      
      expect(output, isEmpty);
    });

    test('Test ShowMissedDoses - With Missed Doses', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(Duration(hours: 1));
      final yesterday = now.subtract(Duration(days: 1));
      
      // Create prescriptions first
      final prescription = Prescription(
        id: 'RX_000001',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'TEST1234567',
        status: PrescriptionStatus.dispensed,
      );
      
      final med1 = Medication(
        id: 'MED_000001',
        name: 'Missed Med 1',
        strength: 100.0,
        form: MedForm.tablet,
        dose: Dose(
          doseId: 'DOSE_001',
          amount: 100.0,
          frequencyPerDay: 1,
          durationInDays: 7,
          startDate: now,
          endDate: now.add(Duration(days: 7)),
          instructions: 'Take daily',
        ),
      );
      
      final med2 = Medication(
        id: 'MED_000002',
        name: 'Missed Med 2',
        strength: 200.0,
        form: MedForm.capsule,
        dose: Dose(
          doseId: 'DOSE_002',
          amount: 200.0,
          frequencyPerDay: 2,
          durationInDays: 7,
          startDate: now,
          endDate: now.add(Duration(days: 7)),
          instructions: 'Take twice daily',
        ),
      );
      
      prescription.addMedication(med1);
      prescription.addMedication(med2);
      JsonHandler.savePrescriptions([prescription]);
      
      // Create missed doses (within last 24 hours, not taken)
      final missedDose1 = DoseIntake(
        id: 'DOSE_MISSED_1',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: oneHourAgo,
        isTaken: false,
      );
      
      final missedDose2 = DoseIntake(
        id: 'DOSE_MISSED_2',
        patientId: 'PAT_000001',
        medicationId: 'MED_000002',
        scheduledTime: yesterday,
        isTaken: false,
      );
      
      // Create taken dose (should not appear)
      final takenDose = DoseIntake(
        id: 'DOSE_TAKEN',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: oneHourAgo,
        isTaken: true,
      );
      
      // Create future dose (should not appear)
      final futureDose = DoseIntake(
        id: 'DOSE_FUTURE',
        patientId: 'PAT_000001',
        medicationId: 'MED_000002',
        scheduledTime: now.add(Duration(hours: 1)),
        isTaken: false,
      );
      
      // Create dose for different patient (should not appear)
      final otherPatientDose = DoseIntake(
        id: 'DOSE_OTHER',
        patientId: 'PAT_000002',
        medicationId: 'MED_000001',
        scheduledTime: oneHourAgo,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([missedDose1, missedDose2, takenDose, futureDose, otherPatientDose]);
      
      // Capture print output
      final output = capturePrint(() {
        ReminderService.showMissedDoses('PAT_000001');
      });
      
      expect(output, contains('❌ MISSED MEDICATIONS'));
      expect(output, contains('Missed Med 1'));
      expect(output, contains('Missed Med 2'));
      expect(output, contains('⏰'));
      expect(output, contains('Missed:'));
    });

    test('Test ShowMissedDoses - More Than 5 Missed Doses', () {
      final now = DateTime.now();
      
      // Create prescription
      final prescription = Prescription(
        id: 'RX_000001',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'TEST1234567',
        status: PrescriptionStatus.dispensed,
      );
      
      // Create more than 5 missed doses
      final missedDoses = List.generate(7, (index) {
        final med = Medication(
          id: 'MED_00000$index',
          name: 'Medication $index',
          strength: 100.0 + index,
          form: MedForm.tablet,
          dose: Dose(
            doseId: 'DOSE_00$index',
            amount: 100.0,
            frequencyPerDay: 1,
            durationInDays: 7,
            startDate: now,
            endDate: now.add(Duration(days: 7)),
            instructions: 'Take daily',
          ),
        );
        prescription.addMedication(med);
        
        return DoseIntake(
          id: 'DOSE_MISSED_$index',
          patientId: 'PAT_000001',
          medicationId: 'MED_00000$index',
          scheduledTime: now.subtract(Duration(hours: index + 1)),
          isTaken: false,
        );
      });
      
      JsonHandler.savePrescriptions([prescription]);
      JsonHandler.saveDoses(missedDoses);
      
      // Capture print output
      final output = capturePrint(() {
        ReminderService.showMissedDoses('PAT_000001');
      });
      
      expect(output, contains('❌ MISSED MEDICATIONS'));
      expect(output, contains('... and 2 more missed doses')); // 7 total - 5 shown = 2 more
    });

    // Test private methods using reflection or by testing their effects through public methods
    test('Test Medication Name Lookup Through Reminders', () {
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
      // Create prescription with medication
      final prescription = Prescription(
        id: 'RX_000001',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'TEST1234567',
        status: PrescriptionStatus.dispensed,
      );
      
      final medication = Medication(
        id: 'MED_000001',
        name: 'Test Medication',
        strength: 500.0,
        form: MedForm.tablet,
        dose: Dose(
          doseId: 'DOSE_000001',
          amount: 500.0,
          frequencyPerDay: 1,
          durationInDays: 7,
          startDate: now,
          endDate: now.add(Duration(days: 7)),
          instructions: 'Take with food',
        ),
      );
      
      prescription.addMedication(medication);
      JsonHandler.savePrescriptions([prescription]);
      
      // Create dose
      final dose = DoseIntake(
        id: 'DOSE_TEST',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: in30Minutes,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([dose]);
      
      // Test that the medication name appears correctly in reminders
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
      
      expect(output, contains('Test Medication 500.0mg'));
    });

    test('Test Medication Name Fallback', () {
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
      // Create dose without corresponding prescription
      final dose = DoseIntake(
        id: 'DOSE_TEST',
        patientId: 'PAT_000001',
        medicationId: 'UNKNOWN_MED',
        scheduledTime: in30Minutes,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([dose]);
      
      // Test that the fallback name appears
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
      
      expect(output, contains('Medication UNKNOWN_MED'));
    });

    test('Test Time Formatting in Output', () {
      final now = DateTime.now();
      final testTime = DateTime(now.year, now.month, now.day, 14, 30); // 2:30 PM
      
      // Create dose with specific time
      final dose = DoseIntake(
        id: 'DOSE_TEST',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: testTime,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([dose]);
      
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
      
      // Should show time in 12-hour format
      expect(output, contains('02:30 PM') || output.contains('02:30'));
    });
  });
}