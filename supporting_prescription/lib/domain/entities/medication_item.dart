import 'package:supporting_prescription/domain/entities/dose.dart';
import 'package:supporting_prescription/domain/entities/dose_intake.dart';
import 'package:supporting_prescription/domain/enums/medication_form.dart';

class Medication {
  final String id;
  final String name;
  final double strength;
  final MedForm form;
  final Dose dose;

  Medication({
    required this.id,
    required this.name,
    required this.strength,
    required this.form,
    required this.dose,
  });

  // In Medication class
  List<DoseIntake> generateSchedule(String patientId) {
    final schedule = <DoseIntake>[];
    final times = _calculateDoseTimes();
    final now = DateTime.now(); // Use current date as start
    
    for (int day = 0; day < dose.durationInDays; day++) {
      final currentDate = now.add(Duration(days: day)); // Start from today
      
      for (int timeIndex = 0; timeIndex < times.length; timeIndex++) {
        final scheduledTime = DateTime(
          currentDate.year,
          currentDate.month, 
          currentDate.day,
          times[timeIndex].hour,
          times[timeIndex].minute,
        );
        
        schedule.add(DoseIntake(
          id: '${id}_D${day}_T$timeIndex',
          patientId: patientId,
          medicationId: id,
          scheduledTime: scheduledTime,
          isTaken: false,
        ));
      }
    }
    
    return schedule;
  }

  List<DateTime> _calculateDoseTimes() {
    final times = <DateTime>[];
    
    switch (dose.frequencyPerDay) {
      case 1:
        // Once daily - morning (8 AM)
        times.add(DateTime(0, 0, 0, 8, 0));
        break;
      case 2:
        // Twice daily - morning (8 AM) and evening (8 PM)
        times.add(DateTime(0, 0, 0, 8, 0));
        times.add(DateTime(0, 0, 0, 20, 0));
        break;
      case 3:
        // Three times daily - morning (8 AM), afternoon (2 PM), evening (8 PM)
        times.add(DateTime(0, 0, 0, 8, 0));
        times.add(DateTime(0, 0, 0, 14, 0));
        times.add(DateTime(0, 0, 0, 20, 0));
        break;
      case 4:
        // Four times daily - 6 AM, 12 PM, 6 PM, 10 PM
        times.add(DateTime(0, 0, 0, 6, 0));
        times.add(DateTime(0, 0, 0, 12, 0));
        times.add(DateTime(0, 0, 0, 18, 0));
        times.add(DateTime(0, 0, 0, 22, 0));
        break;
      default:
        // Default to once daily at 8 AM
        times.add(DateTime(0, 0, 0, 8, 0));
    }
    
    return times;
  }
}