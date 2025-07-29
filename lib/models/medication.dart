import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String name;
  final String description;
  final String dosage;
  final String frequency;
  final String timing; // 식전/식후
  final List<String> sideEffects;
  final double price;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> interactions;

  Medication({
    required this.id,
    required this.name,
    required this.description,
    required this.dosage,
    required this.frequency,
    required this.timing,
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
      description: json['description'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      timing: json['timing'],
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      price: json['price']?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      interactions: List<String>.from(json['interactions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dosage': dosage,
      'frequency': frequency,
      'timing': timing,
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
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
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
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'isVoiceEnabled': isVoiceEnabled,
      'message': message,
    };
  }
} 