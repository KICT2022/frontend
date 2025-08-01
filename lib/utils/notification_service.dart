import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize({bool requestPermissions = true}) async {
    // 시간대 데이터 초기화
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: requestPermissions,
          requestBadgePermission: requestPermissions,
          requestSoundPermission: requestPermissions,
        );

    // Windows 초기화 설정
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          linux: initializationSettingsLinux,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 알림 클릭 이벤트 리스너 설정
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response);
      },
    );

    // 권한 요청이 필요한 경우에만 요청
    if (requestPermissions) {
      await _requestPermissions();
    }
  }

  static void _handleNotificationTap(NotificationResponse response) {
    print('알림 클릭됨: ${response.payload}');

    // 알림 탭으로 이동
    if (response.payload != null) {
      // 전역 변수나 Provider를 통해 알림 화면으로 이동
      // 이 부분은 나중에 구현
    }
  }

  static Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();

      // Android 12 이상에서 정확한 알람 권한 요청
      try {
        await androidImplementation.requestExactAlarmsPermission();
      } catch (e) {
        print('정확한 알람 권한 요청 실패: $e');
      }
    }
  }

  // 즉시 알림 테스트용 함수
  static Future<void> showTestNotification() async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'test_notification',
            '테스트 알림',
            channelDescription: '테스트용 알림입니다.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails();

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        99999,
        '테스트 알림 💊',
        '알림이 정상적으로 작동합니다!',
        platformChannelSpecifics,
        payload: 'test_notification',
      );

      print('테스트 알림 발송 성공');
    } catch (e) {
      print('테스트 알림 발송 실패: $e');
      rethrow;
    }
  }

  static Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required DateTime scheduledDate,
    String? note,
  }) async {
    try {
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

      // 시간대 변환을 더 안전하게 처리
      tz.TZDateTime scheduledTZDateTime;
      try {
        scheduledTZDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
      } catch (e) {
        // 시간대 변환 실패 시 현재 시간 기준으로 설정
        scheduledTZDateTime = tz.TZDateTime.now(tz.local).add(
          Duration(
            milliseconds:
                scheduledDate.millisecondsSinceEpoch -
                DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }

      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZDateTime,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'medication_reminder_$id',
        );
      } catch (e) {
        // 정확한 알람이 허용되지 않는 경우 일반 알람으로 대체
        print('정확한 알람 설정 실패, 일반 알람으로 대체: $e');
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZDateTime,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'medication_reminder_$id',
        );
      }
    } catch (e) {
      print('알림 설정 오류: $e');
      rethrow;
    }
  }

  static Future<void> schedulePreMedicationReminder({
    required int id,
    required String medicationName,
    required DateTime medicationTime,
    String? note,
  }) async {
    try {
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

      // 시간대 변환을 더 안전하게 처리
      tz.TZDateTime reminderTZDateTime;
      try {
        reminderTZDateTime = tz.TZDateTime.from(reminderTime, tz.local);
      } catch (e) {
        // 시간대 변환 실패 시 현재 시간 기준으로 설정
        reminderTZDateTime = tz.TZDateTime.now(tz.local).add(
          Duration(
            milliseconds:
                reminderTime.millisecondsSinceEpoch -
                DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }

      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id + 10000, // 5분 전 알림은 원래 ID + 10000으로 구분
          title,
          body,
          reminderTZDateTime,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        // 정확한 알람이 허용되지 않는 경우 일반 알람으로 대체
        print('준비 알림 정확한 알람 설정 실패, 일반 알람으로 대체: $e');
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id + 10000,
          title,
          body,
          reminderTZDateTime,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      print('준비 알림 설정 오류: $e');
      rethrow;
    }
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
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      print('예약된 알림 조회 오류: $e');
      return [];
    }
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
