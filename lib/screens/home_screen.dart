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
  final _searchController = TextEditingController();

  // 건강 포춘쿠키 메시지 리스트
  final List<String> _healthMessages = [
    '하루 8잔의 물을 마시면 신진대사가 활발해집니다.',
    '규칙적인 운동은 면역력을 높여줍니다.',
    '충분한 수면은 기억력 향상에 도움이 됩니다.',
    '과일과 채소를 충분히 섭취하면 항산화 효과가 있습니다.',
    '스트레칭은 근육 긴장을 풀어주어 혈액순환을 돕습니다.',
    '규칙적인 식사 시간은 소화기 건강에 좋습니다.',
    '깊은 호흡은 스트레스 해소에 효과적입니다.',
    '햇빛을 15분 정도 쬐면 비타민 D 합성이 촉진됩니다.',
    '녹차의 카테킨은 항산화 물질로 건강에 유익합니다.',
    '규칙적인 배변은 대장 건강의 지표입니다.',
    '적절한 체중 관리가 관절 건강을 보호합니다.',
    '금연은 폐 기능 회복에 도움이 됩니다.',
    '소금 섭취를 줄이면 혈압 관리에 좋습니다.',
    '충분한 단백질 섭취는 근육 건강에 필수입니다.',
    '오메가-3 지방산은 심장 건강에 유익합니다.',
  ];

  @override
  void initState() {
    super.initState();
    // 약간의 지연 후 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  // 오늘의 건강 포춘쿠키 메시지 가져오기
  String _getTodayHealthMessage() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    return _healthMessages[dayOfYear % _healthMessages.length];
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
              const SizedBox(width: 4),
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
                  // 약 통합 검색 위젯
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
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: '약 통합 검색',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Icon(
                            Icons.search,
                            size: 40,
                            color: Color(0xFF174D4D),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 오늘의 건강 포춘쿠키
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cookie,
                                size: 48,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '오늘의 건강 포춘쿠키',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '매일 새로운 건강 지식을 만나보세요',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.orange.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.orange.shade200,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 32,
                                  color: Colors.orange.shade600,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getTodayHealthMessage(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade800,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 28,
                                color: Color(0xFFFFD700),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '주간 복용 달성률',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF174D4D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 기존 달성률 위젯 활용
                          _buildAchievementItem('월', 85, isSeniorMode, 14),
                          _buildAchievementItem('화', 92, isSeniorMode, 14),
                          _buildAchievementItem('수', 78, isSeniorMode, 14),
                          _buildAchievementItem('목', 95, isSeniorMode, 14),
                          _buildAchievementItem('금', 88, isSeniorMode, 14),
                          _buildAchievementItem('토', 90, isSeniorMode, 14),
                          _buildAchievementItem('일', 82, isSeniorMode, 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
      padding: EdgeInsets.symmetric(vertical: isSeniorMode ? 4.0 : 3.0),
      child: Row(
        children: [
          SizedBox(
            width: isSeniorMode ? 32.0 : 28.0,
            child: Text(
              day,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              height: isSeniorMode ? 10.0 : 8.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(isSeniorMode ? 5.0 : 4.0),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(
                      isSeniorMode ? 5.0 : 4.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isSeniorMode ? 10.0 : 8.0),
          SizedBox(
            width: isSeniorMode ? 32.0 : 28.0,
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
