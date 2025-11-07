class DoseIntake {
  final String id;
  final String patientId;
  final String medicationId;
  bool isTaken;
  final DateTime scheduledTime;
  
  DoseIntake({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.scheduledTime, 
    this.isTaken = false,
  });
  
   bool markTaken() {
    if (!isTaken) {
      isTaken = true;
      return true;
    }
    return false;
  }
}