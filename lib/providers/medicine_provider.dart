import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediminder/firestore/firestore_data_schema.dart';
import 'package:mediminder/repositories/medicine_repository.dart';
import 'package:mediminder/services/notification_service.dart';

class MedicineProvider with ChangeNotifier {
  final MedicineRepository _repository = MedicineRepository();
  final NotificationService _notificationService = NotificationService();

  List<Patient> _patients = [];
  List<MedicineReminder> _reminders = [];
  List<MedicineReminder> _todayReminders = [];
  List<DoseHistory> _history = [];
  Map<String, int> _statistics = {};
  bool _isLoading = false;
  String _error = '';

  List<Patient> get patients => _patients;
  List<MedicineReminder> get reminders => _reminders;
  List<MedicineReminder> get todayReminders => _todayReminders;
  List<DoseHistory> get history => _history;
  Map<String, int> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Patient operations
  Future<void> loadPatients() async {
    _setLoading(true);
    try {
      _patients = await _repository.getPatients();
      _setError('');
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addPatient(Patient patient) async {
    try {
      await _repository.addPatient(patient);
      await loadPatients();
      _setError('');
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      await _repository.updatePatient(patient);
      await loadPatients();
      _setError('');
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deletePatient(String patientId) async {
    try {
      await _repository.deletePatient(patientId);
      await loadPatients();
      await loadReminders();
      _setError('');
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Reminder operations
  Future<void> loadReminders() async {
    _setLoading(true);
    try {
      _reminders = await _repository.getReminders();
      _setError('');
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTodayReminders() async {
    try {
      _todayReminders = await _repository.getTodayReminders();
      _setError('');
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> addReminder(MedicineReminder reminder) async {
    try {
      await _repository.addReminder(reminder);
      await _notificationService.scheduleReminder(reminder);
      await loadReminders();
      await loadTodayReminders();
      _setError('');
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateReminder(MedicineReminder reminder) async {
    try {
      await _repository.updateReminder(reminder);
      await _notificationService.scheduleReminder(reminder);
      await loadReminders();
      await loadTodayReminders();
      _setError('');
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _repository.deleteReminder(reminderId);
      await _notificationService.cancelReminder(reminderId);
      await loadReminders();
      await loadTodayReminders();
      _setError('');
    } catch (e) {
      _setError(e.toString());
    }
  }

  // History operations
  Future<void> loadHistory({
    String? category,
    String? medicine,
    String? patientId,
  }) async {
    _setLoading(true);
    try {
      _history = await _repository.getHistory(
        category: category,
        medicine: medicine,
        patientId: patientId,
      );
      _setError('');
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> recordDose(MedicineReminder reminder, DoseStatus status) async {
    try {
      final history = DoseHistory(
        id: '',
        reminderId: reminder.id,
        patientId: reminder.patientId,
        patientName: reminder.patientName,
        medicine: reminder.medicine,
        dose: reminder.dose,
        category: reminder.category,
        scheduledTime: reminder.nextSchedule,
        takenTime: status == DoseStatus.taken ? DateTime.now() : null,
        status: status,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        createdAt: DateTime.now(),
      );

      await _repository.recordDose(history);

      // Update next schedule for the reminder
      final nextSchedule = _calculateNextSchedule(reminder);
      final updatedReminder = reminder.copyWith(nextSchedule: nextSchedule);
      await _repository.updateReminder(updatedReminder);

      await loadTodayReminders();
      await loadStatistics();
      _setError('');
    } catch (e) {
      _setError(e.toString());
    }
  }

  DateTime _calculateNextSchedule(MedicineReminder reminder) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    // Find the next scheduled time today
    for (final timeStr in reminder.times) {
      final timeParts = timeStr.split(':');
      final scheduleHour = int.parse(timeParts[0]);
      final scheduleMinute = int.parse(timeParts[1]);

      if (scheduleHour > currentHour ||
          (scheduleHour == currentHour && scheduleMinute > currentMinute)) {
        return DateTime(
          now.year,
          now.month,
          now.day,
          scheduleHour,
          scheduleMinute,
        );
      }
    }

    // If no more times today, schedule for first time tomorrow
    final firstTime = reminder.times.first;
    final timeParts = firstTime.split(':');
    final tomorrow = now.add(const Duration(days: 1));

    return DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  // Statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _repository.getStatistics();
      _setError('');
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Initialize data
  Future<void> initializeData() async {
    await loadPatients();
    await loadReminders();
    await loadTodayReminders();
    await loadStatistics();
  }

  // Get unique categories from reminders
  List<String> getCategories() {
    final categories = _reminders.map((r) => r.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Get unique medicines from reminders
  List<String> getMedicines() {
    final medicines = _reminders.map((r) => r.medicine).toSet().toList();
    medicines.sort();
    return medicines;
  }
}
