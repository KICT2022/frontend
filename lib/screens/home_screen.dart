import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/medication_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 약간의 지연 후 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final medicationProvider = Provider.of<MedicationProvider>(
        context,
        listen: false,
      );
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );

      await medicationProvider.loadMedications();
      await notificationProvider.loadSettings();
    } catch (e) {
      // 오류 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final isSeniorMode = notificationProvider.isSeniorMode;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FA), // 밝은 그레이 배경
          appBar: AppBar(
            title: const Text(
              '방구석 약사',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFF174D4D), // 고급스러운 청록
                letterSpacing: 1.2,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 2,
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: Color(0xFF174D4D),
                        ),
                        onPressed: () => context.go('/notifications'),
                      ),
                      if (notificationProvider.unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '${notificationProvider.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFF174D4D)),
                onPressed: () => context.go('/settings'),
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_pharmacy,
                            size: 48,
                            color: Color(0xFF174D4D),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '오늘의 복약',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF174D4D),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '복약 알림 및 관리',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 테스트 알림 추가 버튼 (개발용)
                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_alert,
                                size: 32,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '테스트 알림 추가',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '새로운 알림을 추가하여 기능을 테스트해보세요',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  notificationProvider.addTestNotification();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('테스트 알림이 추가되었습니다!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  '추가',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 32,
                                color: Color(0xFFFFD700),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '주간 복용 달성률',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF174D4D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 기존 달성률 위젯 활용
                          _buildAchievementItem('월', 85, isSeniorMode, 16),
                          _buildAchievementItem('화', 92, isSeniorMode, 16),
                          _buildAchievementItem('수', 78, isSeniorMode, 16),
                          _buildAchievementItem('목', 95, isSeniorMode, 16),
                          _buildAchievementItem('금', 88, isSeniorMode, 16),
                          _buildAchievementItem('토', 90, isSeniorMode, 16),
                          _buildAchievementItem('일', 82, isSeniorMode, 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 추가 섹션 필요시 여기에 Card로 추가
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  // 이미 홈 화면이므로 아무것도 하지 않음
                  break;
                case 1:
                  context.go('/search');
                  break;
                case 2:
                  context.go('/medication');
                  break;
                case 3:
                  context.go('/profile');
                  break;
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildAchievementItem(
    String day,
    int percentage,
    bool isSeniorMode,
    double fontSize,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSeniorMode ? 6.0 : 4.0),
      child: Row(
        children: [
          SizedBox(
            width: isSeniorMode ? 40.0 : 30.0,
            child: Text(
              day,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              height: isSeniorMode ? 12.0 : 8.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(isSeniorMode ? 6.0 : 4.0),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(
                      isSeniorMode ? 6.0 : 4.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isSeniorMode ? 12.0 : 8.0),
          SizedBox(
            width: isSeniorMode ? 40.0 : 30.0,
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
