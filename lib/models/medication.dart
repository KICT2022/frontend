import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String name;
  final String? genericName; // 일반명 추가
  final String? manufacturer; // 제조사 추가
  final String description;
  final String dosage;
  final String frequency;
  final String timing; // 식전/식후
  final String? indications; // 적응증 추가
  final String? precautions; // 주의사항 추가
  final List<String> sideEffects;
  final double price;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> interactions;

  Medication({
    required this.id,
    required this.name,
    this.genericName,
    this.manufacturer,
    required this.description,
    required this.dosage,
    required this.frequency,
    required this.timing,
    this.indications,
    this.precautions,
    this.sideEffects = const [],
    this.price = 0.0,
    this.imageUrl = '',
    this.ingredients = const [],
    this.interactions = const [],
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      genericName: json['genericName'],
      manufacturer: json['manufacturer'],
      description: json['description'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      timing: json['timing'],
      indications: json['indications'],
      precautions: json['precautions'],
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      price: json['price']?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      interactions: List<String>.from(json['interactions'] ?? []),
    );
  }

  // fromMap 메서드 추가 (fromJson과 동일)
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      genericName: map['genericName'],
      manufacturer: map['manufacturer'],
      description: map['description'],
      dosage: map['dosage'],
      frequency: map['frequency'] ?? '',
      timing: map['timing'] ?? '',
      indications: map['indications'],
      precautions: map['precautions'],
      sideEffects:
          map['sideEffects'] != null
              ? (map['sideEffects'] is String
                  ? [map['sideEffects']]
                  : List<String>.from(map['sideEffects']))
              : const [],
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      interactions: List<String>.from(map['interactions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'manufacturer': manufacturer,
      'description': description,
      'dosage': dosage,
      'frequency': frequency,
      'timing': timing,
      'indications': indications,
      'precautions': precautions,
      'sideEffects': sideEffects,
      'price': price,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'interactions': interactions,
    };
  }
}

class MedicationSchedule {
  final String id;
  final String medicationId;
  final String medicationName;
  final TimeOfDay time;
  final List<int> daysOfWeek; // 1=월요일, 2=화요일, ...,
  final bool isActive;
  final String? note;

  MedicationSchedule({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.time,
    required this.daysOfWeek,
    this.isActive = true,
    this.note,
  });

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    return MedicationSchedule(
      id: json['id'],
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      time: TimeOfDay(
        hour: json['time']['hour'],
        minute: json['time']['minute'],
      ),
      daysOfWeek: List<int>.from(json['daysOfWeek']),
      isActive: json['isActive'] ?? true,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'time': {'hour': time.hour, 'minute': time.minute},
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'note': note,
    };
  }
}

class MedicationReminder {
  final String id;
  final String medicationId;
  final String medicationName;
  final TimeOfDay time;
  final List<int> daysOfWeek;
  final bool isActive;
  final bool isVoiceEnabled;
  final String? message;

  MedicationReminder({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.time,
    required this.daysOfWeek,
    this.isActive = true,
    this.isVoiceEnabled = false,
    this.message,
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    return MedicationReminder(
      id: json['id'],
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      time: TimeOfDay(
        hour: json['time']['hour'],
        minute: json['time']['minute'],
      ),
      daysOfWeek: List<int>.from(json['daysOfWeek']),
      isActive: json['isActive'] ?? true,
      isVoiceEnabled: json['isVoiceEnabled'] ?? false,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'time': {'hour': time.hour, 'minute': time.minute},
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'isVoiceEnabled': isVoiceEnabled,
      'message': message,
    };
  }
}

// 복용 완료 상태를 관리하는 클래스
class MedicationDosage {
  final String id;
  final String medicationId;
  final String medicationName;
  final TimeOfDay time;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? note;

  MedicationDosage({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.time,
    this.isCompleted = false,
    this.completedAt,
    this.note,
  });

  MedicationDosage copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    TimeOfDay? time,
    bool? isCompleted,
    DateTime? completedAt,
    String? note,
  }) {
    return MedicationDosage(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
    );
  }

  factory MedicationDosage.fromJson(Map<String, dynamic> json) {
    return MedicationDosage(
      id: json['id'],
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      time: TimeOfDay(
        hour: json['time']['hour'],
        minute: json['time']['minute'],
      ),
      isCompleted: json['isCompleted'] ?? false,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'time': {'hour': time.hour, 'minute': time.minute},
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'note': note,
    };
  }
}

// 통합된 약 알림 클래스 (같은 약의 여러 시간대를 하나로 묶음)
class IntegratedMedicationReminder {
  final String medicationId;
  final String medicationName;
  final List<MedicationDosage> dosages;
  final String? note;
  final bool isActive;

  IntegratedMedicationReminder({
    required this.medicationId,
    required this.medicationName,
    required this.dosages,
    this.note,
    this.isActive = true,
  });

  // 오늘 복용해야 할 총 횟수
  int get totalDosages => dosages.length;

  // 완료된 복용 횟수
  int get completedDosages => dosages.where((d) => d.isCompleted).length;

  // 완료율
  double get completionRate =>
      totalDosages > 0 ? completedDosages / totalDosages : 0.0;

  // 모든 복용이 완료되었는지
  bool get isFullyCompleted => completedDosages == totalDosages;

  factory IntegratedMedicationReminder.fromDosages(
    List<MedicationDosage> dosages,
  ) {
    if (dosages.isEmpty) {
      throw ArgumentError('Dosages cannot be empty');
    }

    final firstDosage = dosages.first;
    return IntegratedMedicationReminder(
      medicationId: firstDosage.medicationId,
      medicationName: firstDosage.medicationName,
      dosages: dosages,
    );
  }

  factory IntegratedMedicationReminder.fromJson(Map<String, dynamic> json) {
    return IntegratedMedicationReminder(
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      dosages:
          (json['dosages'] as List)
              .map((d) => MedicationDosage.fromJson(d))
              .toList(),
      note: json['note'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosages': dosages.map((d) => d.toJson()).toList(),
      'note': note,
      'isActive': isActive,
    };
  }
}
