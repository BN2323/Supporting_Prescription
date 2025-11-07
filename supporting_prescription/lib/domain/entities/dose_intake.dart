class DoseIntake {
  final String id;
  bool isTaken;
  final DateTime scheduledTime;
  
  DoseIntake({required this.id, required this.scheduledTime, this.isTaken = false});
  
  bool markTaken() {
    isTaken = true;
    return isTaken;
  }
}