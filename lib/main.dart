import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/user_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/reminder_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/medication_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/medication_search_result_screen.dart';
import 'screens/drug_interaction_result_screen.dart';
import 'screens/profile_edit_screen.dart';

import 'utils/notification_service.dart';

// 전역 NotificationProvider 접근을 위한 변수
NotificationProvider? globalNotificationProvider;

// NotificationService에서 전역 NotificationProvider를 설정하는 함수
void setGlobalNotificationProvider(NotificationProvider provider) {
  globalNotificationProvider = provider;
  // NotificationService에 전역 provider 설정
  NotificationService.setGlobalProvider(provider);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences 초기화
  await SharedPreferences.getInstance();

  // 알림 서비스 초기화 (권한 요청은 나중에)
  try {
    await NotificationService.initialize(requestPermissions: false);
  } catch (e) {
    print('앱 시작 시 알림 서비스 초기화 실패: $e');
  }

  // 성능 최적화를 위한 설정
  if (Platform.isAndroid) {
    // Android에서 렌더링 성능 개선
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            // 앱 시작 시 토큰 초기화 및 자동 로그인 확인
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authProvider.initialize();
            });
            return authProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) {
            try {
              final provider = NotificationProvider();
              globalNotificationProvider = provider;
              setGlobalNotificationProvider(provider);
              return provider;
            } catch (e) {
              print('NotificationProvider 생성 실패: $e');
              return NotificationProvider();
            }
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            try {
              final provider = ReminderProvider();
              // NotificationProvider와 연결
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  final notificationProvider =
                      Provider.of<NotificationProvider>(context, listen: false);
                  provider.setNotificationCallback((title, message, type) {
                    try {
                      notificationProvider.addNotification(
                        title: title,
                        message: message,
                        timestamp: DateTime.now(),
                        type: type,
                      );
                    } catch (e) {
                      print('알림 추가 실패: $e');
                    }
                  });
                } catch (e) {
                  print('NotificationProvider 연결 실패: $e');
                }
              });
              return provider;
            } catch (e) {
              print('ReminderProvider 생성 실패: $e');
              return ReminderProvider();
            }
          },
        ),
      ],
      child: MaterialApp.router(
        title: '방구석 약사',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'NotoSansKR',
          // 성능 최적화를 위한 설정
          useMaterial3: true,
          // 스크롤 성능 개선
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(Colors.grey.shade400),
            trackColor: WidgetStateProperty.all(Colors.grey.shade200),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        routerConfig: _createRouter(),
        debugShowCheckedModeBanner: false,
        // 성능 최적화 옵션
        showPerformanceOverlay: false,
        showSemanticsDebugger: false,
      ),
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        // 알림 클릭으로 인한 딥링크 처리
        final uri = state.uri;
        if (uri.queryParameters.containsKey('notification')) {
          return '/notifications';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/medication',
          builder: (context, state) => const MedicationScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: '/medication-search-result',
          builder: (context, state) {
            final searchQuery = state.extra as String;
            return MedicationSearchResultScreen(searchQuery: searchQuery);
          },
        ),
        GoRoute(
          path: '/drug-interaction-result',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return DrugInteractionResultScreen(
              drugNames: data['drugNames'] as List<String>,
              result: data['result'] as String,
              data: data['data'] as Map<String, dynamic>?,
            );
          },
        ),
        GoRoute(
          path: '/profile-edit',
          builder: (context, state) => const ProfileEditScreen(),
        ),
      ],
    );
  }
}
