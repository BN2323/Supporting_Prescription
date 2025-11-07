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
  
  bool requestRenewal(String patientId, String prescriptionId) {
    try {
      final renewals = JsonHandler.loadRenewals();
      
      // Check if renewal already exists
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
  
  bool processRenewal(String renewalId, bool approve, String note) {
    try {
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
      
      // TEMPORARY FIX: Return all today's doses since DoseIntake doesn't have patientId
      return doses.where((dose) =>
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
      
      // TEMPORARY FIX: Return all doses sorted by time
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
      
      // TEMPORARY FIX: Return all upcoming doses
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
  
  // New method to get medication adherence rate
  double getAdherenceRate(String patientId) {
    final doses = JsonHandler.loadDoses();
    
    // TEMPORARY FIX: Calculate adherence for all doses
    if (doses.isEmpty) return 0.0;
    
    final takenDoses = doses.where((d) => d.isTaken).length;
    return (takenDoses / doses.length) * 100;
  }
}