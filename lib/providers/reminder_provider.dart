import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/notification_service.dart';

class ReminderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _reminders = [];
  // 복용 완료 상태를 저장하는 맵 (날짜_알림ID_시간대 -> bool)
  Map<String, bool> _completionStatus = {};

  List<Map<String, dynamic>> get reminders => _reminders;
  Map<String, bool> get completionStatus => _completionStatus;

  // NotificationProvider에 접근하기 위한 콜백 함수
  Function(String title, String message, String type)? onNotificationAdded;

  void setNotificationCallback(
    Function(String title, String message, String type) callback,
  ) {
    onNotificationAdded = callback;
  }

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

    // 푸시 알림 설정
    _scheduleNotificationsForReminder(newId, medicationName, time, days, note);

    // 복약 일정 추가 완료 알림
    _showScheduleAddedNotification(medicationName, time, days);

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
      // 기존 알림 취소
      NotificationService.cancelNotification(id);

      _reminders[index] = {
        'id': id,
        'text': reminderText,
        'time': timeString,
        'days': days,
        'note': note,
      };

      // 새로운 푸시 알림 설정
      _scheduleNotificationsForReminder(
        id,
        medicationName,
        timeString,
        days,
        note,
      );

      // 복약 일정 수정 완료 알림
      _showScheduleUpdatedNotification(medicationName, timeString, days);

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
    // 삭제할 알림 정보 저장
    final reminderToDelete = _reminders.firstWhere(
      (reminder) => reminder['id'] == id,
      orElse: () => {},
    );

    // 알림 취소
    NotificationService.cancelNotification(id);

    _reminders.removeWhere((reminder) => reminder['id'] == id);
    // 해당 알림과 관련된 완료 상태도 삭제
    _completionStatus.removeWhere((key, value) => key.contains('_${id}_'));

    // 복약 일정 삭제 완료 알림
    if (reminderToDelete.isNotEmpty) {
      _showScheduleDeletedNotification(reminderToDelete['text'] ?? '알 수 없는 약');
    }

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

  // 알림에 대한 푸시 알림을 설정하는 메서드
  void _scheduleNotificationsForReminder(
    int id,
    String medicationName,
    String timeString,
    List<String> days,
    String note,
  ) {
    // 시간 문자열을 TimeOfDay 리스트로 변환
    final List<TimeOfDay> times = [];
    final timeList = timeString.split(', ');

    for (final timeStr in timeList) {
      final timeParts = timeStr.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          times.add(TimeOfDay(hour: hour, minute: minute));
        }
      }
    }

    // 주간 반복 알림 설정
    NotificationService.scheduleWeeklyMedicationReminders(
      baseId: id,
      medicationName: medicationName,
      times: times,
      days: days,
      note: note.isNotEmpty ? note : null,
    );
  }

  // 복약 일정 추가 완료 알림을 표시하는 메서드
  void _showScheduleAddedNotification(
    String medicationName,
    String time,
    List<String> days,
  ) {
    final daysText = _formatDaysText(days);
    final notificationText =
        '${medicationName} • ${daysText} • ${time} 복용 알림이 설정되었습니다.';

    NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000, // 고유 ID 생성
      title: '알림 설정 완료',
      body: notificationText,
      payload: 'schedule_added',
    );

    // 앱 내 알림 목록에도 추가
    if (onNotificationAdded != null) {
      onNotificationAdded!('알림 설정 완료', notificationText, 'medication');
    }
  }

  // 복약 일정 수정 완료 알림을 표시하는 메서드
  void _showScheduleUpdatedNotification(
    String medicationName,
    String time,
    List<String> days,
  ) {
    final daysText = _formatDaysText(days);
    final notificationText =
        '${medicationName} • ${daysText} • ${time} 복용 알림이 수정되었습니다.';

    NotificationService.showNotification(
      id: (DateTime.now().millisecondsSinceEpoch + 1) % 100000, // 고유 ID 생성
      title: '알림 수정 완료',
      body: notificationText,
      payload: 'schedule_updated',
    );

    // 앱 내 알림 목록에도 추가
    if (onNotificationAdded != null) {
      onNotificationAdded!('알림 수정 완료', notificationText, 'medication');
    }
  }

  // 복약 일정 삭제 완료 알림을 표시하는 메서드
  void _showScheduleDeletedNotification(String medicationName) {
    final notificationText = '${medicationName} 복용 알림이 삭제되었습니다. 알림이 취소되었습니다.';

    NotificationService.showNotification(
      id: (DateTime.now().millisecondsSinceEpoch + 2) % 100000, // 고유 ID 생성
      title: '알림 삭제 완료',
      body: notificationText,
      payload: 'schedule_deleted',
    );

    // 앱 내 알림 목록에도 추가
    if (onNotificationAdded != null) {
      onNotificationAdded!('알림 삭제 완료', notificationText, 'medication');
    }
  }
}
