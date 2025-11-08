import 'package:supporting_prescription/domain/entities/prescription.dart';
import 'package:supporting_prescription/domain/enums/prescription_status.dart';

import '../../data/json_handler.dart';
import '../../domain/entities/dose_intake.dart';
import '../../domain/entities/renewal_request.dart';
import '../../domain/enums/renewal_status.dart';

class MedicationService {
  bool markDoseAsTaken(String doseId) {
    try {
      final doses = JsonHandler.loadDoses();
      final doseIndex = doses.indexWhere((d) => d.id == doseId);
      
      if (doseIndex == -1) {
        print('Dose not found');
        return false;
      }
      
      final dose = doses[doseIndex];


      final prescriptions = JsonHandler.loadPrescriptions();
      final prescription = _findPrescriptionForMedication(dose.medicationId, prescriptions);
      
      if (prescription == null || prescription.status != PrescriptionStatus.dispensed) {
        print('❌ Cannot take medication - prescription not dispensed yet');
        return false;
      }
      
      if (!dose.isTaken) {
        dose.markTaken();
        JsonHandler.saveDoses(doses);
        print('✅ Dose recorded as taken');
        return true;
      } else {
        print('⚠️ Dose was already taken');
        return false;
      }
    } catch (e) {
      print('Error marking dose: $e');
      return false;
    }
  }
  

  Prescription? _findPrescriptionForMedication(String medicationId, List<Prescription> prescriptions) {
    for (final prescription in prescriptions) {
      final hasMedication = prescription.medications.any((med) => med.id == medicationId);
      if (hasMedication) {
        return prescription;
      }
    }
    return null;
  }
  
  bool requestRenewal(String patientId, String prescriptionId) {
    try {
      final renewals = JsonHandler.loadRenewals();
      

      if (renewals.any((r) => r.patientId == patientId && r.prescriptionId == prescriptionId && r.status == RenewalStatus.pending)) {
        print('⚠️ Renewal request already pending');
        return false;
      }
      
      final renewal = RenewalRequest(
        id: JsonHandler.getNextId('renewal'),
        patientId: patientId,
        prescriptionId: prescriptionId,
        status: RenewalStatus.pending,
      );
      
      renewals.add(renewal);
      JsonHandler.saveRenewals(renewals);
      print('✅ Renewal request submitted');
      return true;
    } catch (e) {
      print('Error requesting renewal: $e');
      return false;
    }
  }
  
  // In MedicationService class
  bool processRenewal(String renewalId, bool approve, String note) {
    try {
      print('note: $note');
      final renewals = JsonHandler.loadRenewals();
      final renewalIndex = renewals.indexWhere((r) => r.id == renewalId);
      
      if (renewalIndex == -1) {
        print('Renewal not found');
        return false;
      }
      
      final renewal = renewals[renewalIndex];
      
      if (approve) {
        renewal.approve(note);
        print('✅ Renewal approved');
      } else {
        renewal.deny(note);
        print('❌ Renewal denied');
      }
      
      print('renuew: ${renewal.doctorNote}');
      // FIX: Save the updated renewals list back to JSON
      JsonHandler.saveRenewals(renewals);
      return true;
    } catch (e) {
      print('Error processing renewal: $e');
      return false;
    }
  }
  
  List<DoseIntake> getTodayDoses(String patientId) {
    try {
      final doses = JsonHandler.loadDoses();
      final today = DateTime.now();
      print('it works');

      return doses.where((dose) =>
        dose.patientId == patientId &&
        dose.scheduledTime.year == today.year &&
        dose.scheduledTime.month == today.month &&
        dose.scheduledTime.day == today.day
      ).toList();
    } catch (e) {
      print('Error loading today doses: $e');
      return [];
    }
  }
  
  List<RenewalRequest> getRenewalRequests(String patientId) {
    try {
      final renewals = JsonHandler.loadRenewals();
      print('renewals out: ${renewals is RenewalRequest}');
      return renewals.where((r) => r.patientId == patientId).toList();
    } catch (e) {
      print('Error loading renewals: $e');
      return [];
    }
  }
  
  List<RenewalRequest> getPendingRenewals() {
    try {
      final renewals = JsonHandler.loadRenewals();
      return renewals.where((r) => r.status == RenewalStatus.pending).toList();
    } catch (e) {
      print('Error loading pending renewals: $e');
      return [];
    }
  }

  bool renewalExists(String renewalId) {
    final renewals = JsonHandler.loadRenewals();
    return renewals.any((r) => r.id == renewalId);
  }

  List<DoseIntake> getDoseHistory(String patientId) {
    try {
      final doses = JsonHandler.loadDoses();
      

      return doses.toList()..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    } catch (e) {
      print('Error loading dose history: $e');
      return [];
    }
  }
  
  List<DoseIntake> getUpcomingDoses(String patientId, {int daysAhead = 7}) {
    try {
      final doses = JsonHandler.loadDoses();
      final now = DateTime.now();
      final endDate = now.add(Duration(days: daysAhead));
      

      return doses.where((dose) =>
        dose.scheduledTime.isAfter(now) &&
        dose.scheduledTime.isBefore(endDate) &&
        !dose.isTaken
      ).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    } catch (e) {
      print('Error loading upcoming doses: $e');
      return [];
    }
  }
  

  double getAdherenceRate(String patientId) {
    final doses = JsonHandler.loadDoses();
    

    if (doses.isEmpty) return 0.0;
    
    final takenDoses = doses.where((d) => d.isTaken).length;
    return (takenDoses / doses.length) * 100;
  }
}