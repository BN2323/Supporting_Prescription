import '../enums/medication_form.dart';
import 'dose.dart';
import 'dose_intake.dart';

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

  List<DoseIntake> generateSchedule() {
    final schedules = <DoseIntake>[];
    int doseCount = 0;

    for (int day = 0; day < dose.durationInDays; day++) {
      final currentDate = dose.startDate.add(Duration(days: day));

      for (int time = 0; time < dose.frequencyPerDay; time++) {
        final hour = 8 + (time * (12 / dose.frequencyPerDay)).toInt();
        final scheduledTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          hour,
        );

        schedules.add(
          DoseIntake(id: '${id}_D${doseCount++}', scheduledTime: scheduledTime),
        );
      }
    }
    return schedules;
  }
}
