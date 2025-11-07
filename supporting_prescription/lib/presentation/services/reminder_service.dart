import 'package:supporting_prescription/data/json_handler.dart';
import 'package:supporting_prescription/domain/entities/dose_intake.dart';

class ReminderService {
  static void checkReminders(String patientId) {
    final doses = _getUpcomingDoses(patientId);
    
    if (doses.isEmpty) {
      return;
    }
    
    final now = DateTime.now();
    final nextHour = now.add(Duration(hours: 1));
    
    final upcomingDoses = doses.where((dose) =>
      dose.scheduledTime.isAfter(now) &&
      dose.scheduledTime.isBefore(nextHour) &&
      !dose.isTaken
    ).toList();
    
    if (upcomingDoses.isNotEmpty) {
      _showReminders(upcomingDoses);
    }
  }
  
  static List<DoseIntake> _getUpcomingDoses(String patientId) {
    try {
      final doses = JsonHandler.loadDoses();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(Duration(days: 1));
      
      return doses.where((dose) =>
        dose.patientId == patientId &&
        dose.scheduledTime.isAfter(now) &&
        dose.scheduledTime.isBefore(tomorrow) &&
        !dose.isTaken
      ).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    } catch (e) {
      print('Error loading upcoming doses for reminders: $e');
      return [];
    }
  }
  
  static void _showReminders(List<DoseIntake> upcomingDoses) {
    print('\n🔔 MEDICATION REMINDERS');
    print('=' * 50);
    
    for (final dose in upcomingDoses) {
      final timeLeft = dose.scheduledTime.difference(DateTime.now());
      final minutesLeft = timeLeft.inMinutes;
      
      String urgency;
      if (minutesLeft <= 15) {
        urgency = '🚨 URGENT';
      } else if (minutesLeft <= 30) {
        urgency = '⚠️ SOON';
      } else {
        urgency = '📋 UPCOMING';
      }
      
      print('$urgency - ${_formatTime(dose.scheduledTime)}');
      print('   Medication: ${_getMedicationNameFromDose(dose)}');
      print('   Time: ${_formatTime(dose.scheduledTime)} (in $minutesLeft minutes)');
      print('   Dose ID: ${dose.id}');
      print('   ${'-' * 40}');
    }
    
    print('\n💡 Tip: Take your medications on time for best results!');
    print('=' * 50);
  }
  
  static String _getMedicationNameFromDose(DoseIntake dose) {
    // This would need access to prescription data to get medication names
    // For now, we'll extract from the dose ID
    try {
      final prescriptions = JsonHandler.loadPrescriptions();
      for (final prescription in prescriptions) {
        for (final medication in prescription.medications) {
          if (medication.id == dose.medicationId) {
            return '${medication.name} ${medication.strength}mg';
          }
        }
      }
    } catch (e) {
      print('Error getting medication name: $e');
    }
    
    // Fallback: parse from dose ID
    return 'Medication ${dose.medicationId}';
  }
  
  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour;
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
  
  static void showMissedDoses(String patientId) {
    final missedDoses = _getMissedDoses(patientId);
    
    if (missedDoses.isNotEmpty) {
      _showMissedReminders(missedDoses);
    }
  }
  
  static List<DoseIntake> _getMissedDoses(String patientId) {
    try {
      final doses = JsonHandler.loadDoses();
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));
      
      return doses.where((dose) =>
        dose.patientId == patientId &&
        dose.scheduledTime.isAfter(yesterday) &&
        dose.scheduledTime.isBefore(now) &&
        !dose.isTaken
      ).toList()..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    } catch (e) {
      print('Error loading missed doses: $e');
      return [];
    }
  }
  
  static void _showMissedReminders(List<DoseIntake> missedDoses) {
    print('\n❌ MISSED MEDICATIONS');
    print('=' * 50);
    
    for (final dose in missedDoses.take(5)) { // Show last 5 missed doses
      print('⏰ ${_formatTime(dose.scheduledTime)} - ${_getMedicationNameFromDose(dose)}');
      print('   Missed: ${_formatDate(dose.scheduledTime)}');
    }
    
    if (missedDoses.length > 5) {
      print('   ... and ${missedDoses.length - 5} more missed doses');
    }
    
    print('\n💡 Tip: Try to take your medications as scheduled!');
    print('=' * 50);
  }
  
  static String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}