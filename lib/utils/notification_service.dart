import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 시간대 데이터 초기화
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Windows 초기화 설정
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          linux: initializationSettingsLinux,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Android 권한 요청
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required DateTime scheduledDate,
    String? note,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'medication_reminder',
          '복약 알림',
          channelDescription: '복약 시간을 알려주는 알림입니다.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final String title = '복약 시간입니다 💊';
    final String body =
        note != null && note.isNotEmpty
            ? '$medicationName 복용 시간입니다. ($note)'
            : '$medicationName 복용 시간입니다.';

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> schedulePreMedicationReminder({
    required int id,
    required String medicationName,
    required DateTime medicationTime,
    String? note,
  }) async {
    // 5분 전 알림 시간 계산
    final DateTime reminderTime = medicationTime.subtract(
      const Duration(minutes: 5),
    );

    // 현재 시간보다 이전이면 알림을 설정하지 않음
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'pre_medication_reminder',
          '복약 준비 알림',
          channelDescription: '복약 5분 전 준비 알림입니다.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final String title = '복약 준비 ⏰';
    final String body = '5분 후 $medicationName 복용 시간입니다. 미리 준비해주세요.';

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id + 10000, // 5분 전 알림은 원래 ID + 10000으로 구분
      title,
      body,
      tz.TZDateTime.from(reminderTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    // 5분 전 알림도 함께 취소
    await _flutterLocalNotificationsPlugin.cancel(id + 10000);
  }

  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // 복약 일정에 따라 반복 알림 설정
  static Future<void> scheduleWeeklyMedicationReminders({
    required int baseId,
    required String medicationName,
    required List<TimeOfDay> times,
    required List<String> days,
    String? note,
  }) async {
    // 기존 알림들 먼저 취소
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < times.length; j++) {
        final int notificationId = baseId * 1000 + i * 10 + j;
        await cancelNotification(notificationId);
      }
    }

    final Map<String, int> dayMap = {
      '월': DateTime.monday,
      '화': DateTime.tuesday,
      '수': DateTime.wednesday,
      '목': DateTime.thursday,
      '금': DateTime.friday,
      '토': DateTime.saturday,
      '일': DateTime.sunday,
    };

    final DateTime now = DateTime.now();

    for (final String day in days) {
      final int? weekday = dayMap[day];
      if (weekday == null) continue;

      for (int timeIndex = 0; timeIndex < times.length; timeIndex++) {
        final TimeOfDay time = times[timeIndex];

        // 다음 해당 요일 찾기
        DateTime nextDate = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        while (nextDate.weekday != weekday || nextDate.isBefore(now)) {
          nextDate = nextDate.add(const Duration(days: 1));
        }

        final int notificationId =
            baseId * 1000 + (weekday - 1) * 10 + timeIndex;

        // 정시 알림 설정
        await scheduleMedicationReminder(
          id: notificationId,
          medicationName: medicationName,
          scheduledDate: nextDate,
          note: note,
        );

        // 5분 전 알림 설정
        await schedulePreMedicationReminder(
          id: notificationId,
          medicationName: medicationName,
          medicationTime: nextDate,
          note: note,
        );
      }
    }
  }
}
