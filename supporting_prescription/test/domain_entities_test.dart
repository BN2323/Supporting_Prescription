import 'package:supporting_prescription/domain/entities/dose.dart';
import 'package:supporting_prescription/domain/entities/dose_intake.dart';
import 'package:supporting_prescription/domain/entities/medication_item.dart';
import 'package:supporting_prescription/domain/entities/prescription.dart';
import 'package:supporting_prescription/domain/entities/renewal_request.dart';
import 'package:supporting_prescription/domain/enums/medication_form.dart';
import 'package:supporting_prescription/domain/enums/prescription_status.dart';
import 'package:supporting_prescription/domain/enums/renewal_status.dart';
import 'package:test/test.dart';

void main() {
  group('Domain Entities Tests', () {
    test('Test Prescription Status Changes', () {
      final prescription = Prescription(
        id: 'RX_000001',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'DEA1234567',
        status: PrescriptionStatus.pending,
      );

      expect(prescription.status, PrescriptionStatus.pending);

      prescription.dispense();
      expect(prescription.status, PrescriptionStatus.dispensed);

      prescription.cancel();
      expect(prescription.status, PrescriptionStatus.cancelled);
    });

    test('Test Prescription Expiration', () {
      final oldPrescription = Prescription(
        id: 'RX_000001',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'DEA1234567',
        status: PrescriptionStatus.dispensed,

        dateIssued: DateTime.now().subtract(Duration(days: 31))
      );

      expect(oldPrescription.isExpired, true);

      final newPrescription = Prescription(
        id: 'RX_000002',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'DEA1234567',
        status: PrescriptionStatus.dispensed,
      );

      expect(newPrescription.isExpired, false);
    });

    test('Test DoseIntake Mark as Taken', () {
      final dose = DoseIntake(
        id: 'DOSE_000001',
        patientId: 'PAT_000001', 
        medicationId: 'MED_000001',
        scheduledTime: DateTime.now(),
        isTaken: false,
      );

      expect(dose.isTaken, false);

      final result = dose.markTaken();
      expect(result, true);
      expect(dose.isTaken, true);


      final secondResult = dose.markTaken();
      expect(secondResult, false);
    });

    test('Test RenewalRequest Status Changes', () {
      final renewal = RenewalRequest(
        id: 'REN_000001',
        patientId: 'PAT_000001',
        prescriptionId: 'RX_000001',
        status: RenewalStatus.pending,
      );

      expect(renewal.status, RenewalStatus.pending);
      expect(renewal.doctorNote, isNull);

      renewal.approve('Approved with note');
      expect(renewal.status, RenewalStatus.approved);
      expect(renewal.doctorNote, 'Approved with note');

      renewal.deny('Denied with reason');
      expect(renewal.status, RenewalStatus.denied);
      expect(renewal.doctorNote, 'Denied with reason');
    });

    test('Test Medication Schedule Generation', () {
      final dose = Dose(
        doseId: 'DOSE_000001',
        amount: 500.0,
        frequencyPerDay: 2,
        durationInDays: 3,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 3),
        instructions: 'Take with food',
      );

      final medication = Medication(
        id: 'MED_000001',
        name: 'Test Medication',
        strength: 500.0,
        form: MedForm.tablet,
        dose: dose,
      );

      final schedule = medication.generateSchedule('PAT_000001');
      

      expect(schedule.length, 6);
      

      expect(schedule[0].id, isNotEmpty);
      expect(schedule[0].patientId, 'PAT_000001');
      expect(schedule[0].medicationId, 'MED_000001');
      expect(schedule[0].scheduledTime, DateTime(2024, 1, 1, 8, 0)); 
      expect(schedule[0].isTaken, false);
      

      expect(schedule[1].id, isNotEmpty);
      expect(schedule[1].patientId, 'PAT_000001');
      expect(schedule[1].medicationId, 'MED_000001');
      expect(schedule[1].scheduledTime, DateTime(2024, 1, 1, 20, 0));
      expect(schedule[1].isTaken, false);
      

      expect(schedule[2].scheduledTime, DateTime(2024, 1, 2, 8, 0)); 
      expect(schedule[4].scheduledTime, DateTime(2024, 1, 3, 8, 0)); 
      
 
      final ids = schedule.map((dose) => dose.id).toSet();
      expect(ids.length, 6);
    });

    test('Test Add Medication to Prescription', () {
      final prescription = Prescription(
        id: 'RX_000001',
        doctorId: 'DOC_000001',
        patientId: 'PAT_000001',
        deaNumber: 'DEA1234567',
        status: PrescriptionStatus.pending,
      );

      expect(prescription.medications.length, 0);

      final medication = Medication(
        id: 'MED_000001',
        name: 'Test Med',
        strength: 100.0,
        form: MedForm.tablet,
        dose: Dose(
          doseId: 'DOSE_000001',
          amount: 100.0,
          frequencyPerDay: 1,
          durationInDays: 10,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 10)),
          instructions: 'Test instructions',
        ),
      );

      prescription.addMedication(medication);
      expect(prescription.medications.length, 1);
      expect(prescription.medications[0].name, 'Test Med');
    });
  });
}