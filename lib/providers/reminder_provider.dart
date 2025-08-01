import 'package:flutter/foundation.dart';

class ReminderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _reminders = [];
  // 복용 완료 상태를 저장하는 맵 (날짜_알림ID_시간대 -> bool)
  Map<String, bool> _completionStatus = {};

  List<Map<String, dynamic>> get reminders => _reminders;
  Map<String, bool> get completionStatus => _completionStatus;

  void addReminder(
    String medicationName,
    String time,
    List<String> days, [
    String note = '',
  ]) {
    final newId = _reminders.isNotEmpty ? _reminders.last['id'] + 1 : 1;
    final daysText = _formatDaysText(days);
    final reminderText =
        note.isNotEmpty
            ? '${medicationName} • ${daysText} • ${time} • ${note}'
            : '${medicationName} • ${daysText} • ${time}';

    _reminders.add({
      'id': newId,
      'text': reminderText,
      'time': time,
      'days': days,
      'note': note,
    });
    notifyListeners();
  }

  void updateReminder(
    int id,
    String medicationName,
    String time,
    List<String> days, [
    String note = '',
  ]) {
    final timeString = time;
    final daysText = _formatDaysText(days);
    final reminderText =
        note.isNotEmpty
            ? '${medicationName} • ${daysText} • ${timeString} • ${note}'
            : '${medicationName} • ${daysText} • ${timeString}';

    final index = _reminders.indexWhere((reminder) => reminder['id'] == id);
    if (index != -1) {
      _reminders[index] = {
        'id': id,
        'text': reminderText,
        'time': timeString,
        'days': days,
        'note': note,
      };
      notifyListeners();
    }
  }

  // 요일 텍스트를 포맷하는 메서드
  String _formatDaysText(List<String> days) {
    // 모든 요일이 선택되어 있으면 "매일"로 표시
    if (days.length == 7 &&
        days.contains('월') &&
        days.contains('화') &&
        days.contains('수') &&
        days.contains('목') &&
        days.contains('금') &&
        days.contains('토') &&
        days.contains('일')) {
      return '매일';
    }
    // 그렇지 않으면 기존 방식대로 쉼표로 구분
    return days.join(', ');
  }

  void deleteReminder(int id) {
    _reminders.removeWhere((reminder) => reminder['id'] == id);
    // 해당 알림과 관련된 완료 상태도 삭제
    _completionStatus.removeWhere((key, value) => key.contains('_${id}_'));
    notifyListeners();
  }

  // 복용 완료 상태를 토글하는 메서드
  void toggleCompletion(int reminderId, String timeSlot) {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final key = '${dateKey}_${reminderId}_$timeSlot';

    _completionStatus[key] = !(_completionStatus[key] ?? false);
    notifyListeners();
  }

  // 특정 알림의 특정 시간대 완료 상태를 확인하는 메서드
  bool isCompleted(int reminderId, String timeSlot) {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final key = '${dateKey}_${reminderId}_$timeSlot';

    return _completionStatus[key] ?? false;
  }

  // 오늘의 모든 완료 상태를 초기화하는 메서드 (테스트용)
  void clearTodayCompletions() {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    _completionStatus.removeWhere((key, value) => key.startsWith(dateKey));
    notifyListeners();
  }
}
