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

  void addReminder(String medicationName, String time, List<String> days) {
    final newId = _reminders.isNotEmpty ? _reminders.last['id'] + 1 : 1;
    final daysText = days.join(', ');
    final reminderText = '${daysText} ${time} ${medicationName} 알림';

    _reminders.add({
      'id': newId,
      'text': reminderText,
      'time': time,
      'days': days,
    });
    notifyListeners();
  }

  void updateReminder(
    int id,
    String medicationName,
    String time,
    List<String> days,
  ) {
    final timeString = time;
    final daysText = days.join(', ');
    final reminderText = '${daysText} ${timeString} ${medicationName} 알림';

    final index = _reminders.indexWhere((reminder) => reminder['id'] == id);
    if (index != -1) {
      _reminders[index] = {
        'id': id,
        'text': reminderText,
        'time': timeString,
        'days': days,
      };
      notifyListeners();
    }
  }

  void deleteReminder(int id) {
    _reminders.removeWhere((reminder) => reminder['id'] == id);
    notifyListeners();
  }
}
