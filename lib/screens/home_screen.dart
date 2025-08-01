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
  final int _currentIndex = 0;
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

  // 일일 건강 스탬프 데이터
  final List<Map<String, dynamic>> _stamps = [
    {
      'title': '물 8잔 마시기',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'completed': false,
    },
    {
      'title': '30분 운동하기',
      'icon': Icons.fitness_center,
      'color': Colors.green,
      'completed': false,
    },
    {
      'title': '과일/채소 섭취',
      'icon': Icons.eco,
      'color': Colors.lightGreen,
      'completed': false,
    },
    {
      'title': '스트레칭하기',
      'icon': Icons.accessibility_new,
      'color': Colors.orange,
      'completed': false,
    },
    {
      'title': '깊은 호흡하기',
      'icon': Icons.air,
      'color': Colors.cyan,
      'completed': false,
    },
    {
      'title': '비타민D 쬐기',
      'icon': Icons.wb_sunny,
      'color': Colors.amber,
      'completed': false,
    },
    {
      'title': '녹차 마시기',
      'icon': Icons.local_drink,
      'color': Colors.teal,
      'completed': false,
    },
    {
      'title': '규칙적 배변',
      'icon': Icons.schedule,
      'color': Colors.brown,
      'completed': false,
    },
  ];

  String _lastResetDate = '';

  @override
  void initState() {
    super.initState();
    // 약간의 지연 후 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _checkDailyReset();
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

  // 일일 초기화 확인
  void _checkDailyReset() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_lastResetDate != today) {
      setState(() {
        _lastResetDate = today;
        for (var stamp in _stamps) {
          stamp['completed'] = false;
        }
      });
    }
  }

  // 스탬프 토글
  void _toggleStamp(int index) {
    setState(() {
      _stamps[index]['completed'] = !_stamps[index]['completed'];
    });
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
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  context.push(
                                    '/medication-search-result',
                                    extra: value.trim(),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              if (_searchController.text.trim().isNotEmpty) {
                                context.push(
                                  '/medication-search-result',
                                  extra: _searchController.text.trim(),
                                );
                              }
                            },
                            child: Icon(
                              Icons.search,
                              size: 40,
                              color: Color(0xFF174D4D),
                            ),
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

                  // 일일 건강 스탬프
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
                                Icons.star,
                                size: 28,
                                color: Colors.amber.shade600,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '일일 건강 스탬프',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF174D4D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 4행 2열 지그재그 스탬프
                          _buildStampsGrid(),
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
                  context.go('/pharmacy-map');
                  break;
                case 3:
                  context.go('/medication');
                  break;
                case 4:
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

  Widget _buildStampsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4, // 4열로 변경
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.8, // 가로 비율 조정
      children: List.generate(_stamps.length, (index) {
        final stamp = _stamps[index];
        final isCompleted = stamp['completed'] as bool;

        return GestureDetector(
          onTap: () => _toggleStamp(index),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? stamp['color'].withOpacity(0.3)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted ? stamp['color'] : Colors.grey.shade300,
                width: isCompleted ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 도장 모양 아이콘
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? stamp['color'] : Colors.grey.shade300,
                    border: Border.all(
                      color:
                          isCompleted ? stamp['color'] : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    stamp['icon'],
                    size: 20,
                    color: isCompleted ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stamp['title'],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? stamp['color'] : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 2),
                  Icon(Icons.check_circle, size: 12, color: stamp['color']),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
