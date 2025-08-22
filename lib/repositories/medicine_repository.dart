import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediminder/firestore/firestore_data_schema.dart';

class MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Patient operations
  Future<List<Patient>> getPatients() async {
    if (_userId.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('patients')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Patient.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get patients: $e');
    }
  }

  Future<void> addPatient(Patient patient) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('patients')
          .add(patient.toJson());
    } catch (e) {
      throw Exception('Failed to add patient: $e');
    }
  }

  Future<void> updatePatient(Patient patient) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('patients')
          .doc(patient.id)
          .update(patient.toJson());
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  Future<void> deletePatient(String patientId) async {
    if (_userId.isEmpty) return;

    try {
      // Delete all reminders for this patient
      final reminders = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders')
          .where('patientId', isEqualTo: patientId)
          .get();

      for (final doc in reminders.docs) {
        await doc.reference.delete();
      }

      // Delete patient
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('patients')
          .doc(patientId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete patient: $e');
    }
  }

  // Reminder operations
  Future<List<MedicineReminder>> getReminders() async {
    if (_userId.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders')
          .where('active', isEqualTo: true)
          .orderBy('nextSchedule')
          .get();

      return snapshot.docs
          .map(
            (doc) => MedicineReminder.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get reminders: $e');
    }
  }

  Future<List<MedicineReminder>> getTodayReminders() async {
    if (_userId.isEmpty) return [];

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders')
          .where('active', isEqualTo: true)
          .where('nextSchedule', isGreaterThanOrEqualTo: startOfDay)
          .where('nextSchedule', isLessThanOrEqualTo: endOfDay)
          .orderBy('nextSchedule')
          .get();

      return snapshot.docs
          .map(
            (doc) => MedicineReminder.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get today\'s reminders: $e');
    }
  }

  Future<void> addReminder(MedicineReminder reminder) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders')
          .add(reminder.toJson());
    } catch (e) {
      throw Exception('Failed to add reminder: $e');
    }
  }

  Future<void> updateReminder(MedicineReminder reminder) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders')
          .doc(reminder.id)
          .update(reminder.toJson());
    } catch (e) {
      throw Exception('Failed to update reminder: $e');
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders')
          .doc(reminderId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }

  // History operations
  Future<List<DoseHistory>> getHistory({
    String? category,
    String? medicine,
    String? patientId,
  }) async {
    if (_userId.isEmpty) return [];

    try {
      Query query = _firestore
          .collection('users')
          .doc(_userId)
          .collection('history');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (medicine != null && medicine.isNotEmpty) {
        query = query.where('medicine', isEqualTo: medicine);
      }

      if (patientId != null && patientId.isNotEmpty) {
        query = query.where('patientId', isEqualTo: patientId);
      }

      final snapshot = await query
          .orderBy('scheduledTime', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map(
            (doc) => DoseHistory.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get history: $e');
    }
  }

  Future<void> recordDose(DoseHistory history) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('history')
          .add(history.toJson());
    } catch (e) {
      throw Exception('Failed to record dose: $e');
    }
  }

  // User profile operations
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_userId.isEmpty) return null;

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore.collection('users').doc(_userId).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Statistics
  Future<Map<String, int>> getStatistics() async {
    if (_userId.isEmpty) return {};

    try {
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));

      final historySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('history')
          .where('scheduledTime', isGreaterThan: lastWeek)
          .get();

      final remindersSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders')
          .where('active', isEqualTo: true)
          .get();

      final patientsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('patients')
          .get();

      final history = historySnapshot.docs
          .map((doc) => DoseHistory.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return {
        'totalReminders': remindersSnapshot.size,
        'totalPatients': patientsSnapshot.size,
        'dosesTaken': history.where((h) => h.status == DoseStatus.taken).length,
        'dosesMissed': history
            .where((h) => h.status == DoseStatus.missed)
            .length,
        'dosesSkipped': history
            .where((h) => h.status == DoseStatus.skipped)
            .length,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}
