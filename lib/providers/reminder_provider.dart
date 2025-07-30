import 'package:flutter/foundation.dart';

class ReminderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _reminders = [
    {
      'id': 1,
      'text': '매일 14시 C약 알림',
      'time': '14:00',
      'days': ['월', '화', '수', '목', '금', '토', '일'],
    },
    {
      'id': 2,
      'text': '월수금 14시, 20시 D약 알림',
      'time': '14:00, 20:00',
      'days': ['월', '수', '금'],
    },
  ];

  List<Map<String, dynamic>> get reminders => _reminders;

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
    notifyListeners();
  }
}
