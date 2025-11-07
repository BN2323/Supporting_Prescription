import '../../data/json_handler.dart';
import '../../domain/entities/dose_intake.dart';
import '../../domain/entities/renewal_request.dart';
import '../../domain/enums/renewal_status.dart';

class MedicationService {
  void markDoseAsTaken(String doseId) {
    final doses = JsonHandler.loadDoses();
    final dose = doses.firstWhere((d) => d.id == doseId);
    
    if (!dose.isTaken) {
      dose.markTaken();
      JsonHandler.saveDoses(doses);
    }
  }
  
  void requestRenewal(String patientId, String prescriptionId) {
    final renewals = JsonHandler.loadRenewals();
    
    final renewal = RenewalRequest(
      id: JsonHandler.getNextId('renewal'),
      patientId: patientId,
      prescriptionId: prescriptionId,
    );
    
    renewals.add(renewal);
    JsonHandler.saveRenewals(renewals);
  }
  
  void processRenewal(String renewalId, bool approve, String note) {
    final renewals = JsonHandler.loadRenewals();
    final renewal = renewals.firstWhere((r) => r.id == renewalId);
    
    if (approve) {
      renewal.approve(note);
    } else {
      renewal.deny(note);
    }
    
    JsonHandler.saveRenewals(renewals);
  }
  
  List<DoseIntake> getTodayDoses(String patientId) {
    final doses = JsonHandler.loadDoses();
    final today = DateTime.now();
    
    return doses.where((dose) =>
      dose.scheduledTime.year == today.year &&
      dose.scheduledTime.month == today.month &&
      dose.scheduledTime.day == today.day
    ).toList();
  }
  
  List<RenewalRequest> getRenewalRequests(String patientId) {
    final renewals = JsonHandler.loadRenewals();
    return renewals.where((r) => r.patientId == patientId).toList();
  }
  
  List<RenewalRequest> getPendingRenewals() {
    final renewals = JsonHandler.loadRenewals();
    return renewals.where((r) => r.status == RenewalStatus.pending).toList();
  }

  bool renewalExists(String renewalId) {
    final renewals = JsonHandler.loadRenewals();
    return renewals.any((r) => r.id == renewalId);
  }

  List<DoseIntake> getDoseHistory(String patientId) {
    final doses = JsonHandler.loadDoses();
    return doses.where((dose) => dose.id.contains(patientId)).toList();
  }
}