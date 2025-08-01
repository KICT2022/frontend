import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../utils/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 약간의 지연 후 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Provider에 안전하게 접근
      final authProvider = context.read<AuthProvider>();

      await authProvider.checkLoginStatus();

      // 앱이 처음 실행되는지 확인
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

      // 알림 권한 요청 (새 사용자에게만)
      await NotificationService.initialize(requestPermissions: isFirstLaunch);

      // 첫 실행이었다면 플래그를 false로 설정
      if (isFirstLaunch) {
        await prefs.setBool('is_first_launch', false);
      }

      if (mounted) {
        if (authProvider.isLoggedIn) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.blue.shade200, width: 3),
              ),
              child: Icon(
                Icons.medication,
                size: 80,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 30),

            // 앱 이름
            const Text(
              '방구석 약사',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '언제 어디서나 건강한 복약 관리',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 50),

            // 로딩 인디케이터
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
