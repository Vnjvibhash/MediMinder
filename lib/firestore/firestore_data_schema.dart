import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Patient copyWith({
    String? name,
    int? age,
    String? gender,
  }) {
    return Patient(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      userId: userId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class MedicineReminder {
  final String id;
  final String patientId;
  final String patientName;
  final String medicine;
  final String dose;
  final String category;
  final List<String> times;
  final List<String> days;
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final String userId;
  final DateTime nextSchedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicineReminder({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.medicine,
    required this.dose,
    required this.category,
    required this.times,
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.active,
    required this.userId,
    required this.nextSchedule,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineReminder.fromJson(Map<String, dynamic> json) {
    return MedicineReminder(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      medicine: json['medicine'] ?? '',
      dose: json['dose'] ?? '',
      category: json['category'] ?? '',
      times: List<String>.from(json['times'] ?? []),
      days: List<String>.from(json['days'] ?? []),
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      active: json['active'] ?? true,
      userId: json['userId'] ?? '',
      nextSchedule: (json['nextSchedule'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'medicine': medicine,
      'dose': dose,
      'category': category,
      'times': times,
      'days': days,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'active': active,
      'userId': userId,
      'nextSchedule': Timestamp.fromDate(nextSchedule),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MedicineReminder copyWith({
    String? patientName,
    String? medicine,
    String? dose,
    String? category,
    List<String>? times,
    List<String>? days,
    DateTime? startDate,
    DateTime? endDate,
    bool? active,
    DateTime? nextSchedule,
  }) {
    return MedicineReminder(
      id: id,
      patientId: patientId,
      patientName: patientName ?? this.patientName,
      medicine: medicine ?? this.medicine,
      dose: dose ?? this.dose,
      category: category ?? this.category,
      times: times ?? this.times,
      days: days ?? this.days,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
      userId: userId,
      nextSchedule: nextSchedule ?? this.nextSchedule,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

enum DoseStatus { taken, missed, skipped }

class DoseHistory {
  final String id;
  final String reminderId;
  final String patientId;
  final String patientName;
  final String medicine;
  final String dose;
  final String category;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final DoseStatus status;
  final String userId;
  final DateTime createdAt;

  DoseHistory({
    required this.id,
    required this.reminderId,
    required this.patientId,
    required this.patientName,
    required this.medicine,
    required this.dose,
    required this.category,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    required this.userId,
    required this.createdAt,
  });

  factory DoseHistory.fromJson(Map<String, dynamic> json) {
    return DoseHistory(
      id: json['id'] ?? '',
      reminderId: json['reminderId'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      medicine: json['medicine'] ?? '',
      dose: json['dose'] ?? '',
      category: json['category'] ?? '',
      scheduledTime: (json['scheduledTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      takenTime: (json['takenTime'] as Timestamp?)?.toDate(),
      status: DoseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => DoseStatus.missed,
      ),
      userId: json['userId'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reminderId': reminderId,
      'patientId': patientId,
      'patientName': patientName,
      'medicine': medicine,
      'dose': dose,
      'category': category,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'status': status.toString().split('.').last,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}