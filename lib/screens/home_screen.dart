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
  final _searchController = TextEditingController();
  final PageController _cardPageController = PageController();
  int _currentCardPage = 0;

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

  // 일별 식단 추천 데이터 리스트
  final List<Map<String, dynamic>> _mealRecommendations = [
    {
      'title': '현미밥 + 닭가슴살 + 채소',
      'description': '단백질과 섬유질이 풍부한\n건강한 한끼 식단입니다',
      'icon': Icons.lunch_dining,
      'color': Colors.green,
      'nutrients': ['단백질', '섬유질', '비타민'],
    },
    {
      'title': '연어 + 퀴노아 + 브로콜리',
      'description': '오메가3와 슈퍼푸드로\n영양 균형을 맞춘 식단',
      'icon': Icons.set_meal,
      'color': Colors.blue,
      'nutrients': ['오메가3', '단백질', '항산화'],
    },
    {
      'title': '아보카도 토스트 + 견과류',
      'description': '건강한 지방과 비타민E로\n에너지 충전 식단',
      'icon': Icons.breakfast_dining,
      'color': Colors.amber,
      'nutrients': ['건강한지방', '비타민E', '식이섬유'],
    },
    {
      'title': '두부 + 김치찌개 + 현미밥',
      'description': '발효식품과 식물성 단백질의\n균형 잡힌 한식',
      'icon': Icons.ramen_dining,
      'color': Colors.red,
      'nutrients': ['식물성단백질', '프로바이오틱스', '비타민C'],
    },
    {
      'title': '그릭요거트 + 베리 + 견과류',
      'description': '프로바이오틱스와 항산화 성분\n가득한 건강 간식',
      'icon': Icons.icecream,
      'color': Colors.purple,
      'nutrients': ['프로바이오틱스', '항산화', '칼슘'],
    },
    {
      'title': '렌틸콩 수프 + 통곡물빵',
      'description': '식물성 단백질과 복합탄수화물\n포만감 높은 식단',
      'icon': Icons.soup_kitchen,
      'color': Colors.orange,
      'nutrients': ['식물성단백질', '복합탄수화물', '철분'],
    },
    {
      'title': '구운 고등어 + 시금치 + 고구마',
      'description': 'DHA와 베타카로틴이 풍부한\n뇌 건강 식단',
      'icon': Icons.dinner_dining,
      'color': Colors.teal,
      'nutrients': ['DHA', '베타카로틴', '칼륨'],
    },
    {
      'title': '치아시드 푸딩 + 과일',
      'description': '슈퍼시드와 비타민이 만나는\n영양 만점 디저트',
      'icon': Icons.cake,
      'color': Colors.pink,
      'nutrients': ['오메가3', '섬유질', '비타민C'],
    },
    {
      'title': '콩나물국밥 + 김',
      'description': '해조류와 콩나물의 만남\n해독과 다이어트 식단',
      'icon': Icons.rice_bowl,
      'color': Colors.lightGreen,
      'nutrients': ['요오드', '비타민K', '저칼로리'],
    },
    {
      'title': '달걀 + 시금치 오믈렛',
      'description': '완전단백질과 엽산이 풍부한\n두뇌 발달 식단',
      'icon': Icons.egg_alt,
      'color': Colors.yellow,
      'nutrients': ['완전단백질', '엽산', '콜린'],
    },
    {
      'title': '병아리콩 샐러드 + 올리브오일',
      'description': '식물성 단백질과 건강한 지방\n심장 건강 식단',
      'icon': Icons.eco,
      'color': Colors.green,
      'nutrients': ['식물성단백질', '불포화지방', '섬유질'],
    },
    {
      'title': '흑미밥 + 버섯볶음 + 된장국',
      'description': '안토시아닌과 베타글루칸\n면역력 강화 식단',
      'icon': Icons.grass,
      'color': Colors.deepPurple,
      'nutrients': ['안토시아닌', '베타글루칸', '식이섬유'],
    },
    {
      'title': '참치 + 아루굴라 샐러드',
      'description': '저지방 고단백과 비타민K\n다이어트 최적 식단',
      'icon': Icons.local_dining,
      'color': Colors.cyan,
      'nutrients': ['저지방단백질', '비타민K', '엽산'],
    },
    {
      'title': '고구마 + 견과류 + 우유',
      'description': '복합탄수화물과 칼슘으로\n성장기 필수 식단',
      'icon': Icons.bakery_dining,
      'color': Colors.deepOrange,
      'nutrients': ['복합탄수화물', '칼슘', '비타민A'],
    },
    {
      'title': '미역국 + 현미밥 + 나물',
      'description': '미네랄과 식이섬유가 풍부한\n산후조리 식단',
      'icon': Icons.water_drop,
      'color': Colors.indigo,
      'nutrients': ['요오드', '철분', '식이섬유'],
    },
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
    _cardPageController.dispose();
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

  // 오늘의 식단 추천 가져오기
  Map<String, dynamic> _getTodayMealRecommendation() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    return _mealRecommendations[dayOfYear % _mealRecommendations.length];
  }

  // 식단 추천 카드 빌드
  Widget _buildMealRecommendationCard() {
    final meal = _getTodayMealRecommendation();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        color: meal['color'].shade50,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 32,
                    color: meal['color'].shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오늘의 식단 추천',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: meal['color'].shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '건강한 식단을 제안해드려요',
                          style: TextStyle(
                            fontSize: 12,
                            color: meal['color'].shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 식단 내용
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: meal['color'].shade200,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: meal['color'].shade100,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 식단명
                      Row(
                        children: [
                          Icon(
                            meal['icon'],
                            size: 20,
                            color: meal['color'].shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              meal['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: meal['color'].shade700,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 설명
                      Expanded(
                        child: Text(
                          meal['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 영양소 태그
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            (meal['nutrients'] as List<String>)
                                .take(3)
                                .map(
                                  (nutrient) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: meal['color'].shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      nutrient,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: meal['color'].shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 건강 포춘쿠키 카드 빌드
  Widget _buildHealthFortuneCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Icon(Icons.cookie, size: 32, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '건강 포춘쿠키',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '오늘의 건강 지식',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 포춘쿠키 내용
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade100,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 24,
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: Text(
                            _getTodayHealthMessage(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
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

                  // 식단 추천과 건강 포춘쿠키 (슬라이드 형식)
                  SizedBox(
                    height: 320,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView(
                            controller: _cardPageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentCardPage = index;
                              });
                            },
                            children: [
                              // 오늘의 식단 추천 카드
                              _buildMealRecommendationCard(),
                              // 건강 포춘쿠키 카드
                              _buildHealthFortuneCard(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 페이지 인디케이터
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _currentCardPage == 0
                                        ? Colors.green.shade600
                                        : Colors.grey.shade300,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _currentCardPage == 1
                                        ? Colors.orange.shade600
                                        : Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                      ],
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
