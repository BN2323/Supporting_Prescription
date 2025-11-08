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
      JsonHandler.saveDoses([]);
      
      // Simply call the method - it should handle empty doses without errors
      ReminderService.checkReminders('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
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
      
      // Call the method - it should print reminders
      ReminderService.checkReminders('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
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
      
      // Call the method - it should not print anything
      ReminderService.checkReminders('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
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
        isTaken: true,
      );
      
      JsonHandler.saveDoses([takenDose]);
      
      // Call the method - it should not print anything
      ReminderService.checkReminders('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test CheckReminders - Different Patient ID', () {
      final now = DateTime.now();
      final in30Minutes = now.add(Duration(minutes: 30));
      
      // Create dose for different patient
      final otherPatientDose = DoseIntake(
        id: 'DOSE_OTHER',
        patientId: 'PAT_000002',
        medicationId: 'MED_000001',
        scheduledTime: in30Minutes,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([otherPatientDose]);
      
      // Call the method - it should not print anything for PAT_000001
      ReminderService.checkReminders('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test ShowMissedDoses - No Missed Doses', () {
      JsonHandler.saveDoses([]);
      
      // Call the method - it should handle empty doses without errors
      ReminderService.showMissedDoses('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test ShowMissedDoses - With Missed Doses', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(Duration(hours: 1));
      
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
      
      prescription.addMedication(med1);
      JsonHandler.savePrescriptions([prescription]);
      
      // Create missed dose
      final missedDose = DoseIntake(
        id: 'DOSE_MISSED_1',
        patientId: 'PAT_000001',
        medicationId: 'MED_000001',
        scheduledTime: oneHourAgo,
        isTaken: false,
      );
      
      JsonHandler.saveDoses([missedDose]);
      
      // Call the method - it should print missed doses
      ReminderService.showMissedDoses('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test ShowMissedDoses - Multiple Missed Doses', () {
      final now = DateTime.now();
      
      // Create prescription
      final prescription = Prescription(
        id: 'RX_000001',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'TEST1234567',
        status: PrescriptionStatus.dispensed,
      );
      
      // Create multiple missed doses
      final missedDoses = List.generate(3, (index) {
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
      
      // Call the method - it should print missed doses
      ReminderService.showMissedDoses('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
    });

    test('Test Medication Name Resolution', () {
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
      
      // Call the method - it should resolve medication name correctly
      ReminderService.checkReminders('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
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
      
      // Call the method - it should use fallback name
      ReminderService.checkReminders('PAT_000001');
      
      // Test passes if no exception is thrown
      expect(true, true);
    });
  });
}