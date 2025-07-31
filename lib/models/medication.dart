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
  final List<int> daysOfWeek; // 1=월요일, 2=화요일, ...
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
