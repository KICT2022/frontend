import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  bool _isSeniorMode = false;
  bool _isVoiceEnabled = false;
  String _language = 'ko';
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  bool get isSeniorMode => _isSeniorMode;
  bool get isVoiceEnabled => _isVoiceEnabled;
  String get language => _language;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isSeniorMode = prefs.getBool('senior_mode') ?? false;
    _isVoiceEnabled = prefs.getBool('voice_enabled') ?? false;
    _language = prefs.getString('language') ?? 'ko';
    notifyListeners();
  }

  Future<void> toggleSeniorMode() async {
    _isSeniorMode = !_isSeniorMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('senior_mode', _isSeniorMode);
    notifyListeners();
  }

  Future<void> toggleVoiceEnabled() async {
    _isVoiceEnabled = !_isVoiceEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_enabled', _isVoiceEnabled);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String message,
    required DateTime timestamp,
    String? type,
  }) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'type': type ?? 'general',
      'isRead': false,
    });
    notifyListeners();
  }

  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> getUnreadNotifications() {
    return _notifications.where((n) => !n['isRead']).toList();
  }

  int get unreadCount => getUnreadNotifications().length;

  // 테스트용 알림 추가 메서드
  void addTestNotification() {
    final types = ['medication', 'reminder', 'warning', 'info'];
    final titles = [
      '복약 시간 알림',
      '약물 상호작용 경고',
      '복용률 달성 축하',
      '새로운 약물 정보',
    ];
    final messages = [
      '아침 약을 복용할 시간입니다.',
      '새로 처방받은 약과 기존 약물 간 상호작용이 있을 수 있습니다.',
      '이번 주 복용률이 95%를 달성했습니다!',
      '새로운 약물 정보가 업데이트되었습니다.',
    ];

    final random = DateTime.now().millisecondsSinceEpoch % 4;
    addNotification(
      title: titles[random],
      message: messages[random],
      timestamp: DateTime.now().subtract(Duration(minutes: random * 10)),
      type: types[random],
    );
  }
} 