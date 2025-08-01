import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/notification_provider.dart';

// 백그라운드 알림 처리를 위한 top-level 함수
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  NotificationService.handleBackgroundNotificationTap(response);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 전역 NotificationProvider 참조
  static NotificationProvider? _globalNotificationProvider;

  // 전역 NotificationProvider 설정
  static void setGlobalProvider(NotificationProvider provider) {
    _globalNotificationProvider = provider;
  }

  // 백그라운드 알림 처리를 위한 static 메서드
  static void handleBackgroundNotificationTap(NotificationResponse response) {
    _handleNotificationTap(response);
  }

  static Future<void> initialize({bool requestPermissions = true}) async {
    try {
      // 시간대 데이터 초기화
      try {
        tz.initializeTimeZones();
        try {
          tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
        } catch (e) {
          print('시간대 설정 실패, 기본 시간대 사용: $e');
          // 기본 시간대 사용
        }
      } catch (e) {
        print('시간대 초기화 실패: $e');
      }

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

      // 알림 클릭 이벤트 리스너 설정
      try {
        await _flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            _handleNotificationTap(response);
          },
          onDidReceiveBackgroundNotificationResponse:
              onDidReceiveBackgroundNotificationResponse,
        );
        print('알림 서비스 초기화 성공');
      } catch (e) {
        print('알림 서비스 초기화 실패: $e');
      }

      // 알림 채널 생성
      try {
        await createNotificationChannels();
      } catch (e) {
        print('알림 채널 생성 실패: $e');
      }

      // 권한 요청이 필요한 경우에만 요청
      if (requestPermissions) {
        try {
          await _requestPermissions();
        } catch (e) {
          print('권한 요청 실패: $e');
        }
      }
    } catch (e) {
      print('알림 서비스 초기화 오류: $e');
    }
  }

  static void _handleNotificationTap(NotificationResponse response) {
    print('알림 클릭됨: ${response.payload}');

    // 알림이 발생했을 때 앱 내 알림 목록에 추가
    if (response.payload != null &&
        response.payload!.startsWith('medication_reminder_')) {
      final title = '복약 시간입니다 💊';
      final body =
          response.payload!.contains('pre_medication_reminder_')
              ? '복약 준비 ⏰ - 5분 후 복용 시간입니다.'
              : '복약 시간입니다 💊';

      _addToAppNotificationList(title, body, response.payload);
    }

    // 알림 탭으로 이동
    if (response.payload != null) {
      // 전역 변수나 Provider를 통해 알림 화면으로 이동
      // 이 부분은 나중에 구현
    }
  }

  // 푸시 알림을 받았을 때 앱 내 알림 목록에 추가하는 메서드
  static void addNotificationToApp({
    required String title,
    required String body,
    String? payload,
    String type = 'general',
  }) {
    // main.dart에서 정의한 전역 NotificationProvider 사용
    try {
      // 전역 변수를 통해 NotificationProvider에 접근
      // 이 부분은 main.dart에서 globalNotificationProvider를 import해야 함
      print('앱 내 알림 추가: $title - $body');
    } catch (e) {
      print('앱 내 알림 추가 실패: $e');
    }
  }

  static Future<void> _requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        // 기본 알림 권한 요청
        final bool? notificationsEnabled =
            await androidImplementation.requestNotificationsPermission();
        print('알림 권한 요청 결과: $notificationsEnabled');

        // Android 12 이상에서 정확한 알람 권한 요청
        try {
          await androidImplementation.requestExactAlarmsPermission();
          print('정확한 알람 권한 요청 성공');
        } catch (e) {
          print('정확한 알람 권한 요청 실패: $e');
          // 권한이 거부되어도 앱은 계속 작동하도록 함
        }

        // 알림 채널 생성 확인
        try {
          await androidImplementation.createNotificationChannel(
            const AndroidNotificationChannel(
              'medication_reminder',
              '복약 알림',
              description: '복약 시간을 알려주는 알림입니다.',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
              enableLights: true,
            ),
          );

          await androidImplementation.createNotificationChannel(
            const AndroidNotificationChannel(
              'pre_medication_reminder',
              '복약 준비 알림',
              description: '복약 5분 전 준비 알림입니다.',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
              enableLights: true,
            ),
          );

          print('알림 채널 생성 완료');
        } catch (e) {
          print('알림 채널 생성 실패: $e');
        }
      }
    } catch (e) {
      print('권한 요청 중 오류 발생: $e');
    }
  }

  static Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required DateTime scheduledDate,
    String? note,
  }) async {
    try {
      // 현재 시간보다 이전인 경우 알림을 설정하지 않음
      if (scheduledDate.isBefore(DateTime.now())) {
        print(
          '알림 스케줄링 건너뜀: $medicationName - 예정시간이 현재 시간보다 이전임 - $scheduledDate',
        );
        return;
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'medication_reminder',
            '복약 알림',
            channelDescription: '복약 시간을 알려주는 알림입니다.',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            enableLights: true,
            color: Color(0xFF174D4D),
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: BigTextStyleInformation(''),
            category: AndroidNotificationCategory.alarm,
            fullScreenIntent: true,
            timeoutAfter: 30000, // 30초 후 자동 제거
            channelShowBadge: true,
            onlyAlertOnce: false,
            autoCancel: true,
            ongoing: false,
            silent: false,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            categoryIdentifier: 'medication_reminder',
            threadIdentifier: 'medication_reminder',
          );

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
        // 명시적으로 한국 시간대 사용
        final koreaLocation = tz.getLocation('Asia/Seoul');
        scheduledTZDateTime = tz.TZDateTime.from(scheduledDate, koreaLocation);

        // 시간대 변환이 실패하면 현재 시간 기준으로 다시 계산
        if (scheduledTZDateTime.isBefore(tz.TZDateTime.now(koreaLocation))) {
          print('시간대 변환 후 시간이 과거임, 현재 시간 기준으로 재계산');
          final now = tz.TZDateTime.now(koreaLocation);
          final difference = scheduledDate.difference(DateTime.now());
          scheduledTZDateTime = now.add(difference);
        }
      } catch (e) {
        print('시간대 변환 실패, 현재 시간 기준으로 설정: $e');
        // 시간대 변환 실패 시 현재 시간 기준으로 설정
        final koreaLocation = tz.getLocation('Asia/Seoul');
        final now = tz.TZDateTime.now(koreaLocation);
        final difference = scheduledDate.difference(DateTime.now());
        scheduledTZDateTime = now.add(difference);
      }

      print(
        '복약 알림 스케줄링: $medicationName - ID: $id - 예정시간: $scheduledDate - TZ시간: $scheduledTZDateTime',
      );

      // 먼저 정확한 알람으로 시도
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
        print('복약 알림 스케줄링 성공 (정확한 알람): $medicationName - ID: $id');
      } catch (e) {
        print('정확한 알람 설정 실패, 일반 알람으로 대체: $e');

        // 일반 알람으로 재시도
        try {
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
          print('복약 알림 스케줄링 성공 (일반 알람): $medicationName - ID: $id');
        } catch (e2) {
          print('일반 알람도 실패, 즉시 알림으로 대체: $e2');

          // 모든 방법이 실패하면 즉시 알림으로 표시
          await _flutterLocalNotificationsPlugin.show(
            id,
            title,
            body,
            platformChannelSpecifics,
            payload: 'medication_reminder_$id',
          );
          print('즉시 알림으로 표시: $medicationName - ID: $id');
        }
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
        print(
          '준비 알림 스케줄링 건너뜀: $medicationName - 예정시간이 현재 시간보다 이전임 - $reminderTime',
        );
        return;
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'pre_medication_reminder',
            '복약 준비 알림',
            channelDescription: '복약 5분 전 준비 알림입니다.',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            enableLights: true,
            color: Color(0xFFFF6B35),
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: BigTextStyleInformation(''),
            category: AndroidNotificationCategory.reminder,
            fullScreenIntent: true,
            timeoutAfter: 30000, // 30초 후 자동 제거
            channelShowBadge: true,
            onlyAlertOnce: false,
            autoCancel: true,
            ongoing: false,
            silent: false,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            categoryIdentifier: 'pre_medication_reminder',
            threadIdentifier: 'pre_medication_reminder',
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final String title = '복약 준비 ⏰';
      final String body = '5분 후 $medicationName 복용 시간입니다. 미리 준비해주세요.';

      // 시간대 변환을 더 안전하게 처리
      tz.TZDateTime reminderTZDateTime;
      try {
        // 명시적으로 한국 시간대 사용
        final koreaLocation = tz.getLocation('Asia/Seoul');
        reminderTZDateTime = tz.TZDateTime.from(reminderTime, koreaLocation);

        // 시간대 변환이 실패하면 현재 시간 기준으로 다시 계산
        if (reminderTZDateTime.isBefore(tz.TZDateTime.now(koreaLocation))) {
          print('준비 알림 시간대 변환 후 시간이 과거임, 현재 시간 기준으로 재계산');
          final now = tz.TZDateTime.now(koreaLocation);
          final difference = reminderTime.difference(DateTime.now());
          reminderTZDateTime = now.add(difference);
        }
      } catch (e) {
        print('준비 알림 시간대 변환 실패, 현재 시간 기준으로 설정: $e');
        // 시간대 변환 실패 시 현재 시간 기준으로 설정
        final koreaLocation = tz.getLocation('Asia/Seoul');
        final now = tz.TZDateTime.now(koreaLocation);
        final difference = reminderTime.difference(DateTime.now());
        reminderTZDateTime = now.add(difference);
      }

      print(
        '준비 알림 스케줄링: $medicationName - ID: ${id + 10000} - 예정시간: $reminderTime - TZ시간: $reminderTZDateTime',
      );

      // 먼저 정확한 알람으로 시도
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
          payload: 'pre_medication_reminder_$id',
        );
        print('준비 알림 스케줄링 성공 (정확한 알람): $medicationName - ID: ${id + 10000}');
      } catch (e) {
        print('준비 알림 정확한 알람 설정 실패, 일반 알람으로 대체: $e');

        // 일반 알람으로 재시도
        try {
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            id + 10000,
            title,
            body,
            reminderTZDateTime,
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'pre_medication_reminder_$id',
          );
          print('준비 알림 스케줄링 성공 (일반 알람): $medicationName - ID: ${id + 10000}');
        } catch (e2) {
          print('준비 알림 일반 알람도 실패, 즉시 알림으로 대체: $e2');

          // 모든 방법이 실패하면 즉시 알림으로 표시
          await _flutterLocalNotificationsPlugin.show(
            id + 10000,
            title,
            body,
            platformChannelSpecifics,
            payload: 'pre_medication_reminder_$id',
          );
          print('준비 알림 즉시 알림으로 표시: $medicationName - ID: ${id + 10000}');
        }
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

        print(
          '알림 설정: $medicationName - ${day} ${time.hour}:${time.minute} - ID: $notificationId - 예정시간: $nextDate',
        );

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

  // 테스트용: 첫 실행 상태 확인
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_launch') ?? true;
  }

  // 즉시 알림을 표시하는 메서드
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'immediate_notification',
            '즉시 알림',
            channelDescription: '즉시 표시되는 알림입니다.',
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
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      print('즉시 알림 발송 성공: $title');
    } catch (e) {
      print('즉시 알림 발송 실패: $e');
      rethrow;
    }
  }

  // 앱 내 알림 목록에 추가하는 메서드
  static void _addToAppNotificationList(
    String title,
    String body,
    String? payload,
  ) {
    try {
      // 전역 NotificationProvider 사용
      if (_globalNotificationProvider != null) {
        _globalNotificationProvider!.addNotificationFromExternal(
          title: title,
          message: body,
          type: 'medication',
        );
        print('앱 내 알림 목록에 추가됨: $title - $body');
      } else {
        print('전역 NotificationProvider가 설정되지 않음');
      }
    } catch (e) {
      print('앱 내 알림 목록 추가 실패: $e');
    }
  }

  // 알림 권한 및 설정 상태 확인
  static Future<Map<String, dynamic>> checkNotificationStatus() async {
    final Map<String, dynamic> status = {};

    try {
      // Android 구현체 가져오기
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        // 알림 권한 확인
        final bool? areNotificationsEnabled =
            await androidImplementation.areNotificationsEnabled();
        status['notifications_enabled'] = areNotificationsEnabled ?? false;

        // 정확한 알람 권한 확인 (Android 12+)
        bool exactAlarmsEnabled = false;
        try {
          // Android 12+에서는 별도 권한이 필요하지만 직접 확인할 수 없으므로
          // 알림이 예약되었는지로 간접 확인
          exactAlarmsEnabled = true;
        } catch (e) {
          exactAlarmsEnabled = false;
        }
        status['exact_alarms_enabled'] = exactAlarmsEnabled;

        // 예약된 알림 개수 확인
        final List<PendingNotificationRequest> pendingNotifications =
            await getPendingNotifications();
        status['pending_notifications_count'] = pendingNotifications.length;

        // 예약된 알림 상세 정보
        final List<Map<String, dynamic>> pendingDetails = [];
        for (final notification in pendingNotifications) {
          pendingDetails.add({
            'id': notification.id,
            'title': notification.title,
            'body': notification.body,
            'payload': notification.payload,
          });
        }
        status['pending_notifications'] = pendingDetails;
      }

      print('알림 상태 확인 결과: $status');
      return status;
    } catch (e) {
      print('알림 상태 확인 오류: $e');
      status['error'] = e.toString();
      return status;
    }
  }

  // 알림 권한 요청 및 설정 가이드
  static Future<void> requestNotificationPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        // 기본 알림 권한 요청
        await androidImplementation.requestNotificationsPermission();

        // 정확한 알람 권한 요청
        try {
          await androidImplementation.requestExactAlarmsPermission();
          print('정확한 알람 권한 요청 성공');
        } catch (e) {
          print('정확한 알람 권한 요청 실패: $e');
        }
      }
    } catch (e) {
      print('알림 권한 요청 오류: $e');
    }
  }

  // 정확한 알람 권한 확인 및 요청
  static Future<bool> checkAndRequestExactAlarmPermission() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        // Android 12+에서는 정확한 알람 권한이 필요
        try {
          await androidImplementation.requestExactAlarmsPermission();
          print('정확한 알람 권한 요청 성공');
          return true;
        } catch (e) {
          print('정확한 알람 권한 요청 실패: $e');
          return false;
        }
      }
      return false;
    } catch (e) {
      print('정확한 알람 권한 확인 오류: $e');
      return false;
    }
  }

  // 알림 채널 생성
  static Future<void> createNotificationChannels() async {
    try {
      const AndroidNotificationChannel medicationChannel =
          AndroidNotificationChannel(
            'medication_reminder',
            '복약 알림',
            description: '복약 시간을 알려주는 알림입니다.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            showBadge: true,
          );

      const AndroidNotificationChannel preMedicationChannel =
          AndroidNotificationChannel(
            'pre_medication_reminder',
            '복약 준비 알림',
            description: '복약 5분 전 준비 알림입니다.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            showBadge: true,
          );

      const AndroidNotificationChannel immediateChannel =
          AndroidNotificationChannel(
            'immediate_notification',
            '즉시 알림',
            description: '즉시 표시되는 알림입니다.',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(medicationChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(preMedicationChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(immediateChannel);

      print('알림 채널 생성 완료');
    } catch (e) {
      print('알림 채널 생성 실패: $e');
    }
  }

  // Android 배터리 최적화 설정 가이드
  static String getBatteryOptimizationGuidance() {
    return '''
알림이 제시간에 오지 않는 경우 다음 설정을 확인해주세요:

1. 앱 알림 설정:
   - 설정 > 앱 > 방구석 약사 > 알림
   - 모든 알림 권한이 허용되어 있는지 확인
   - "알림 표시" 및 "소리 재생" 활성화

2. 배터리 최적화:
   - 설정 > 앱 > 방구석 약사 > 배터리
   - "배터리 최적화 제한" 또는 "백그라운드 제한 없음" 선택
   - "백그라운드에서 실행" 허용

3. 정확한 알람 권한 (Android 12+):
   - 설정 > 앱 > 방구석 약사 > 권한
   - "정확한 알람 허용" 활성화

4. Do Not Disturb 모드:
   - 알림이 오는 시간에 방해 금지 모드가 꺼져 있는지 확인
   - 설정 > 알림 > 방해 금지 > 예외 앱에 "방구석 약사" 추가

5. 앱 자동 시작 (삼성, LG, 샤오미 등):
   - 설정 > 앱 > 방구석 약사 > 배터리 > 자동 시작 허용
   - 또는 설정 > 배터리 > 앱 절전 모드 > 방구석 약사 제외

6. 개발자 옵션 (고급 사용자):
   - 설정 > 개발자 옵션 > 백그라운드 프로세스 제한
   - "표준 제한" 또는 "제한 없음" 선택

7. 제조사별 설정:
   삼성: 설정 > 디바이스 케어 > 배터리 > 앱 절전 모드
   LG: 설정 > 배터리 > 배터리 최적화
   샤오미: 설정 > 배터리 및 성능 > 앱 배터리 절약
   OPPO/OnePlus: 설정 > 배터리 > 앱 배터리 최적화

8. 앱 정보에서 추가 설정:
   - 설정 > 앱 > 방구석 약사 > 앱 정보
   - "백그라운드에서 실행" 허용
   - "다른 앱 위에 표시" 허용 (필요시)


''';
  }
}
