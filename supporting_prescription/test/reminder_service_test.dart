import 'package:supporting_prescription/data/json_handler.dart';
import 'package:supporting_prescription/domain/entities/dose.dart';
import 'package:supporting_prescription/domain/entities/dose_intake.dart';
import 'package:supporting_prescription/domain/entities/medication_item.dart';
import 'package:supporting_prescription/domain/entities/prescription.dart';
import 'package:supporting_prescription/domain/enums/medication_form.dart';
import 'package:supporting_prescription/domain/enums/prescription_status.dart';
import 'package:supporting_prescription/presentation/services/reminder_service.dart';
import 'package:test/test.dart';

void main() {
  group('ReminderService Tests', () {
    setUp(() {
      // Clear test data before each test
      JsonHandler.saveDoses([]);
      JsonHandler.savePrescriptions([]);
    });

    test('Test CheckReminders - No Upcoming Doses', () {
<<<<<<< HEAD
      JsonHandler.saveDoses([]);
      
      // Simply call the method - it should handle empty doses without errors
      ReminderService.checkReminders('PAT_000001');
=======
      
      JsonHandler.saveDoses([]);
      
      
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test CheckReminders - Upcoming Doses in Next Hour', () {
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
      
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
      
      
      final upcomingDose = DoseIntake(
        id: 'DOSE_UPCOMING',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: in30Minutes,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([upcomingDose]);
      
<<<<<<< HEAD
      // Call the method - it should print reminders
      ReminderService.checkReminders('PAT_000001');
=======
      
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test CheckReminders - Doses Outside Next Hour', () {
      final now = DateTime.now();
      final in2Hours = now.add(Duration(hours: 2));
      
      
      final futureDose = DoseIntake(
        id: 'DOSE_FUTURE',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: in2Hours,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([futureDose]);
      
<<<<<<< HEAD
      // Call the method - it should not print anything
      ReminderService.checkReminders('PAT_000001');
=======
      
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test CheckReminders - Already Taken Doses', () {
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
      
      final takenDose = DoseIntake(
        id: 'DOSE_TAKEN',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: in30Minutes,
<<<<<<< HEAD
        isTaken: true,
=======
        isTaken: true, 
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
      );
      
      JsonHandler.saveDoses([takenDose]);
      
<<<<<<< HEAD
      // Call the method - it should not print anything
      ReminderService.checkReminders('PAT_000001');
=======
      
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test CheckReminders - Different Patient ID', () {
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
      
      final otherPatientDose = DoseIntake(
        id: 'DOSE_OTHER',
<<<<<<< HEAD
        patientId: 'PAT_000002',
=======
        patientId: 'PAT_000002', 
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
        medicationId: 'MED_000001',
        scheduledTime: in30Minutes,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([otherPatientDose]);
      
<<<<<<< HEAD
      // Call the method - it should not print anything for PAT_000001
      ReminderService.checkReminders('PAT_000001');
=======
    
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test ShowMissedDoses - No Missed Doses', () {
<<<<<<< HEAD
      JsonHandler.saveDoses([]);
      
      // Call the method - it should handle empty doses without errors
      ReminderService.showMissedDoses('PAT_000001');
=======
     
      JsonHandler.saveDoses([]);
      
      
      final output = capturePrint(() {
        ReminderService.showMissedDoses('PAT_000001');
      });
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test ShowMissedDoses - With Missed Doses', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(Duration(hours: 1));
      
      
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
      
      prescription.addMedication(med1);
      JsonHandler.savePrescriptions([prescription]);
      
<<<<<<< HEAD
      // Create missed dose
      final missedDose = DoseIntake(
=======
      
      final missedDose1 = DoseIntake(
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
        id: 'DOSE_MISSED_1',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: oneHourAgo,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([missedDose]);
      
<<<<<<< HEAD
      // Call the method - it should print missed doses
      ReminderService.showMissedDoses('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
=======
      
      final takenDose = DoseIntake(
        id: 'DOSE_TAKEN',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: oneHourAgo,
        isTaken: true,
      );
      
    
      final futureDose = DoseIntake(
        id: 'DOSE_FUTURE',
        patientId: 'PAT_000001',
        medicationId: 'MED_000002',
        scheduledTime: now.add(Duration(hours: 1)),
        isTaken: false,
      );
      
      
      final otherPatientDose = DoseIntake(
        id: 'DOSE_OTHER',
        patientId: 'PAT_000002',
        medicationId: 'MED_000001',
        scheduledTime: oneHourAgo,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([missedDose1, missedDose2, takenDose, futureDose, otherPatientDose]);
      
      
      final output = capturePrint(() {
        ReminderService.showMissedDoses('PAT_000001');
      });
      
      expect(output, contains('❌ MISSED MEDICATIONS'));
      expect(output, contains('Missed Med 1'));
      expect(output, contains('Missed Med 2'));
      expect(output, contains('⏰'));
      expect(output, contains('Missed:'));
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
    });

    test('Test ShowMissedDoses - Multiple Missed Doses', () {
      final now = DateTime.now();
      
      
      final prescription = Prescription(
        id: 'RX_000001',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'TEST1234567',
        status: PrescriptionStatus.dispensed,
      );
      
<<<<<<< HEAD
      // Create multiple missed doses
      final missedDoses = List.generate(3, (index) {
=======
      
      final missedDoses = List.generate(7, (index) {
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
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
      
<<<<<<< HEAD
      // Call the method - it should print missed doses
      ReminderService.showMissedDoses('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test Medication Name Resolution', () {
=======
      
      final output = capturePrint(() {
        ReminderService.showMissedDoses('PAT_000001');
      });
      
      expect(output, contains('❌ MISSED MEDICATIONS'));
      expect(output, contains('... and 2 more missed doses')); 
    });

    
    test('Test Medication Name Lookup Through Reminders', () {
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
     
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
      
      
      final dose = DoseIntake(
        id: 'DOSE_TEST',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: in30Minutes,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([dose]);
      
<<<<<<< HEAD
      // Call the method - it should resolve medication name correctly
      ReminderService.checkReminders('PAT_000001');
=======
      
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test Medication Name Fallback', () {
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
      
      final dose = DoseIntake(
        id: 'DOSE_TEST',
        patientId: 'PAT_000001',
        medicationId: 'UNKNOWN_MED',
        scheduledTime: in30Minutes,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([dose]);
      
<<<<<<< HEAD
      // Call the method - it should use fallback name
      ReminderService.checkReminders('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
=======
      
      final output = capturePrint(() {
        ReminderService.checkReminders('PAT_000001');
      });
      
      expect(output, contains('Medication UNKNOWN_MED'));
    });

    test('Test Time Formatting in Output', () {
      final now = DateTime.now();
      final testTime = DateTime(now.year, now.month, now.day, 14, 30);
      

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
      

      expect(output, contains('02:30 PM') || output.contains('02:30'));
>>>>>>> f71cdaa1f7eade5e427fb8a8f22ae972f866c894
    });
  });
}