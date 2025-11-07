class Dose {
  final String doseId;
  final double amount;
  final int frequencyPerDay;
  final int durationInDays;
  final DateTime startDate;
  final DateTime endDate;
  final String instructions;
  
  Dose({required this.doseId, required this.amount, required this.frequencyPerDay, required this.durationInDays,
       required this.startDate, required this.endDate, required this.instructions});
}
