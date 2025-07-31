import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationProvider extends ChangeNotifier {
  List<Medication> _medications = [];
  List<MedicationSchedule> _schedules = [];
  List<MedicationReminder> _reminders = [];
  final List<String> _selectedSymptoms = [];
  bool _isLoading = false;

  List<Medication> get medications => _medications;
  List<MedicationSchedule> get schedules => _schedules;
  List<MedicationReminder> get reminders => _reminders;
  List<String> get selectedSymptoms => _selectedSymptoms;
  bool get isLoading => _isLoading;

  // 임시 약물 데이터
  void _loadSampleData() {
    _medications = [
      Medication(
        id: '1',
        name: '타이레놀',
        description: '해열, 진통제',
        dosage: '15세 이하: 1알, 15세 이상: 2알',
        frequency: '1일 2회',
        timing: '식후',
        sideEffects: ['구역질', '복통'],
        price: 5000.0,
        ingredients: ['아세트아미노펜'],
        interactions: ['와파린', '아스피린'],
      ),
      Medication(
        id: '2',
        name: '화이투벤',
        description: '감기약',
        dosage: '1회 1포',
        frequency: '1일 3회',
        timing: '식후',
        sideEffects: ['졸림', '구역질'],
        price: 3000.0,
        ingredients: ['아세트아미노펜', '구아이페네신'],
        interactions: ['타이레놀'],
      ),
    ];

    _schedules = [
      MedicationSchedule(
        id: '1',
        medicationId: '1',
        medicationName: 'A약',
        time: const TimeOfDay(hour: 8, minute: 0),
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        note: '식전 30분',
      ),
      MedicationSchedule(
        id: '2',
        medicationId: '2',
        medicationName: 'B약',
        time: const TimeOfDay(hour: 12, minute: 0),
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        note: '식후 30분',
      ),
    ];

    _reminders = [
      MedicationReminder(
        id: '1',
        medicationId: '3',
        medicationName: 'C약',
        time: const TimeOfDay(hour: 14, minute: 0),
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        message: '매일 14시 C약 알림',
      ),
      MedicationReminder(
        id: '2',
        medicationId: '4',
        medicationName: 'D약',
        time: const TimeOfDay(hour: 20, minute: 0),
        daysOfWeek: [1, 3, 5],
        message: '월수금 14시, 20시 D약 알림',
      ),
    ];
  }

  Future<void> loadMedications() async {
    if (_medications.isNotEmpty) return; // 이미 로드된 경우 스킵

    _isLoading = true;
    notifyListeners();

    try {
      // 실제 구현에서는 API 호출
      await Future.delayed(const Duration(milliseconds: 500));
      _loadSampleData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Medication>> searchMedications(String query) async {
    if (query.isEmpty) return [];

    return _medications
        .where(
          (med) =>
              med.name.toLowerCase().contains(query.toLowerCase()) ||
              med.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<List<Medication>> getMedicationsBySymptoms(
    List<String> symptoms,
  ) async {
    // 실제 구현에서는 AI 기반 약물 추천
    return _medications.take(3).toList();
  }

  Future<Map<String, dynamic>> checkDrugInteraction(
    String medication1,
    String medication2,
  ) async {
    // 실제 구현에서는 약물 상호작용 API 호출
    await Future.delayed(const Duration(seconds: 1));

    return {
      'canTakeTogether': true,
      'interval': '1시간',
      'warning': '타이레놀과 화이투벤은 1시간 복용간격을 가지면 가능합니다.',
      'medication1': {
        'name': '타이레놀',
        'dosage': '15세 이하: 1알, 15세 이상: 2알, 1일 2회',
      },
      'medication2': {'name': '화이투벤', 'dosage': '1회 1포, 1일 3회'},
    };
  }

  void addSymptom(String symptom) {
    if (!_selectedSymptoms.contains(symptom)) {
      _selectedSymptoms.add(symptom);
      notifyListeners();
    }
  }

  void removeSymptom(String symptom) {
    _selectedSymptoms.remove(symptom);
    notifyListeners();
  }

  void clearSymptoms() {
    _selectedSymptoms.clear();
    notifyListeners();
  }

  Future<void> addMedicationSchedule(MedicationSchedule schedule) async {
    _schedules.add(schedule);
    notifyListeners();
  }

  Future<void> updateMedicationSchedule(MedicationSchedule schedule) async {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
      notifyListeners();
    }
  }

  Future<void> deleteMedicationSchedule(String scheduleId) async {
    _schedules.removeWhere((s) => s.id == scheduleId);
    notifyListeners();
  }

  Future<void> addMedicationReminder(MedicationReminder reminder) async {
    _reminders.add(reminder);
    notifyListeners();
  }

  Future<void> updateMedicationReminder(MedicationReminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      notifyListeners();
    }
  }

  Future<void> deleteMedicationReminder(String reminderId) async {
    _reminders.removeWhere((r) => r.id == reminderId);
    notifyListeners();
  }

  List<MedicationSchedule> getTodaySchedules() {
    final today = DateTime.now().weekday;
    return _schedules
        .where(
          (schedule) =>
              schedule.daysOfWeek.contains(today) && schedule.isActive,
        )
        .toList();
  }

  List<MedicationReminder> getTodayReminders() {
    final today = DateTime.now().weekday;
    return _reminders
        .where(
          (reminder) =>
              reminder.daysOfWeek.contains(today) && reminder.isActive,
        )
        .toList();
  }
}
