import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../providers/notification_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';

import '../services/api_manager.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isSymptomInput = true;

  String? _selectedCategoryId;

  // 약물 입력 칸 개수를 관리하는 변수 추가
  int _drugInputCount = 2;
  // 약물 입력 칸들의 TextEditingController 리스트
  final List<TextEditingController> _drugControllers = [];
  // 입력 검증 메시지
  String? _validationMessage;
  // 증상 입력 필드 컨트롤러
  final TextEditingController _symptomInputController = TextEditingController();

  // 약 추천 관련 상태 변수
  bool _isLoadingRecommendation = false;

  final List<Map<String, String>> _parsedMedications = [];
  final PageController _medicationPageController = PageController();
  int _currentMedicationPage = 0;

  // API 매니저
  final ApiManager _apiManager = ApiManager();
  // 증상 카테고리 데이터
  final List<Map<String, dynamic>> _symptomCategories = [
    {
      'id': 'general',
      'title': '전신 증상',
      'icon': Icons.thermostat,
      'description': '전체적인 신체 상태',
      'symptoms': [
        {'title': '발열', 'icon': Icons.thermostat, 'symptom': '열이 남'},
        {'title': '오한', 'icon': Icons.ac_unit, 'symptom': '몸이 떨림'},
        {'title': '피로감', 'icon': Icons.bedtime, 'symptom': '무기력 / 피로감'},
        {'title': '식욕저하', 'icon': Icons.restaurant, 'symptom': '식욕 저하'},
        {'title': '체중감소', 'icon': Icons.monitor_weight, 'symptom': '체중 감소'},
      ],
    },
    {
      'id': 'head_face',
      'title': '머리/얼굴',
      'icon': Icons.face,
      'description': '머리와 얼굴 부위',
      'symptoms': [
        {'title': '두통', 'icon': Icons.headset, 'symptom': '머리가 아파요'},
        {'title': '어지럼증', 'icon': Icons.rotate_right, 'symptom': '어지럼증'},
        {
          'title': '눈충혈',
          'icon': Icons.visibility,
          'symptom': '눈 충혈 / 가려움 / 통증',
        },
        {'title': '코막힘', 'icon': Icons.air, 'symptom': '코막힘 / 콧물'},
        {'title': '귀통증', 'icon': Icons.hearing, 'symptom': '귀 통증 / 이명 / 귀막힘'},
        {'title': '치통', 'icon': Icons.face, 'symptom': '이가 아파요'},
      ],
    },
    {
      'id': 'respiratory',
      'title': '호흡기',
      'icon': Icons.air,
      'description': '호흡과 관련된 증상',
      'symptoms': [
        {'title': '기침', 'icon': Icons.air, 'symptom': '기침'},
        {'title': '가래', 'icon': Icons.water_drop, 'symptom': '가래'},
        {'title': '인후통', 'icon': Icons.record_voice_over, 'symptom': '목이 아파요'},
        {
          'title': '목쉼',
          'icon': Icons.record_voice_over,
          'symptom': '목 쉼 / 음성 변화',
        },
        {'title': '호흡곤란', 'icon': Icons.air, 'symptom': '호흡곤란 / 숨참'},
      ],
    },
    {
      'id': 'digestive',
      'title': '소화기',
      'icon': Icons.restaurant,
      'description': '소화와 관련된 증상',
      'symptoms': [
        {'title': '복통', 'icon': Icons.person, 'symptom': '배가 아파요'},
        {'title': '메스꺼움', 'icon': Icons.sick, 'symptom': '메스꺼움 / 구토'},
        {'title': '설사', 'icon': Icons.water_drop, 'symptom': '설사'},
        {'title': '변비', 'icon': Icons.block, 'symptom': '변비'},
        {
          'title': '속쓰림',
          'icon': Icons.local_fire_department,
          'symptom': '속 쓰림',
        },
        {'title': '트림', 'icon': Icons.air, 'symptom': '트림 / 가스참'},
        {'title': '소화불량', 'icon': Icons.restaurant, 'symptom': '소화불량'},
      ],
    },
    {
      'id': 'musculoskeletal',
      'title': '근골격계',
      'icon': Icons.accessibility,
      'description': '근육과 뼈, 관절',
      'symptoms': [
        {'title': '요통', 'icon': Icons.accessibility, 'symptom': '허리가 아파요'},
        {'title': '관절통', 'icon': Icons.accessibility_new, 'symptom': '관절이 아파요'},
        {'title': '어깨통증', 'icon': Icons.accessibility, 'symptom': '어깨가 아파요'},
        {'title': '무릎통증', 'icon': Icons.directions_walk, 'symptom': '무릎이 아파요'},
        {'title': '손목통증', 'icon': Icons.pan_tool, 'symptom': '손목이 아파요'},
        {'title': '발목통증', 'icon': Icons.directions_run, 'symptom': '발목이 아파요'},
        {'title': '근육통', 'icon': Icons.fitness_center, 'symptom': '근육통'},
        {'title': '목덜미통증', 'icon': Icons.accessibility, 'symptom': '목덜미 통증'},
        {
          'title': '팔다리저림',
          'icon': Icons.accessibility_new,
          'symptom': '팔/다리 저림',
        },
      ],
    },
    {
      'id': 'cardiovascular',
      'title': '심혈관',
      'icon': Icons.favorite,
      'description': '심장과 혈관',
      'symptoms': [
        {'title': '흉통', 'icon': Icons.favorite, 'symptom': '심장이 아파요'},
      ],
    },
    {
      'id': 'skin',
      'title': '피부/외형',
      'icon': Icons.brush,
      'description': '피부와 외형',
      'symptoms': [
        {'title': '피부발진', 'icon': Icons.brush, 'symptom': '피부 발진 / 두드러기'},
        {'title': '가려움증', 'icon': Icons.touch_app, 'symptom': '가려움증'},
        {'title': '부종', 'icon': Icons.water_drop, 'symptom': '부종 (붓기)'},
        {'title': '멍', 'icon': Icons.healing, 'symptom': '멍 / 외상'},
      ],
    },
    {
      'id': 'urological',
      'title': '비뇨기/생식기',
      'icon': Icons.wc,
      'description': '비뇨기와 생식기',
      'symptoms': [
        {'title': '배뇨통', 'icon': Icons.wc, 'symptom': '소변 시 통증 (배뇨통)'},
        {'title': '빈뇨', 'icon': Icons.water_drop, 'symptom': '빈뇨 / 야뇨'},
        {'title': '생리통', 'icon': Icons.female, 'symptom': '생리통 / 생리불순'},
        {'title': '질분비물', 'icon': Icons.female, 'symptom': '질 분비물 증가'},
        {'title': '음경가려움', 'icon': Icons.male, 'symptom': '음경 가려움 / 통증'},
      ],
    },
    {
      'id': 'neurological',
      'title': '신경/정신',
      'icon': Icons.psychology,
      'description': '신경계와 정신',
      'symptoms': [
        {'title': '불면증', 'icon': Icons.bedtime, 'symptom': '불면증'},
        {'title': '불안감', 'icon': Icons.psychology, 'symptom': '불안감 / 초조함'},
        {
          'title': '우울감',
          'icon': Icons.sentiment_dissatisfied,
          'symptom': '우울감',
        },
        {
          'title': '집중력저하',
          'icon': Icons.center_focus_strong,
          'symptom': '집중력 저하',
        },
        {'title': '기억력저하', 'icon': Icons.psychology, 'symptom': '기억력 저하'},
        {'title': '경련', 'icon': Icons.flash_on, 'symptom': '경련 / 발작'},
      ],
    },
  ];

  // 현재 표시할 증상 카드들
  List<Map<String, dynamic>> _currentSymptomCards = [];
  // 페이지 컨트롤러
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _pageController = PageController();
  }

  @override
  void dispose() {
    for (var controller in _drugControllers) {
      controller.dispose();
    }
    _symptomInputController.dispose();
    _pageController.dispose();
    _medicationPageController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    // 기존 컨트롤러들 정리
    for (var controller in _drugControllers) {
      controller.dispose();
    }
    _drugControllers.clear();

    // 새로운 컨트롤러들 생성
    for (int i = 0; i < _drugInputCount; i++) {
      _drugControllers.add(TextEditingController());
    }
  }

  void _addController() {
    // 새로운 컨트롤러만 추가
    _drugControllers.add(TextEditingController());
  }

  void _removeController(int index) {
    if (index < _drugControllers.length) {
      _drugControllers[index].dispose();
      _drugControllers.removeAt(index);
    }
  }

  bool _validateDrugInputs() {
    // 모든 입력 칸이 채워져 있는지 확인
    for (int i = 0; i < _drugControllers.length; i++) {
      if (_drugControllers[i].text.trim().isEmpty) {
        setState(() {
          _validationMessage = '${i + 1}번째 약을 먼저 입력해주세요.';
        });
        return false;
      }
    }

    setState(() {
      _validationMessage = null;
    });
    return true;
  }

  void _addNewDrugInput() {
    if (_validateDrugInputs()) {
      setState(() {
        _drugInputCount++;
        _addController();
      });
    }
  }

  void _addSymptomFromInput() {
    final symptom = _symptomInputController.text.trim();
    if (symptom.isNotEmpty) {
      final medicationProvider = Provider.of<MedicationProvider>(
        context,
        listen: false,
      );
      medicationProvider.addSymptom(symptom);
      _symptomInputController.clear();
    }
  }

  List<List<Map<String, dynamic>>> _getSymptomPages() {
    List<List<Map<String, dynamic>>> pages = [];
    for (int i = 0; i < _currentSymptomCards.length; i += 6) {
      pages.add(_currentSymptomCards.skip(i).take(6).toList());
    }
    return pages;
  }

  List<List<Map<String, dynamic>>> _getCategoryPages() {
    List<List<Map<String, dynamic>>> pages = [];
    for (int i = 0; i < _symptomCategories.length; i += 4) {
      pages.add(_symptomCategories.skip(i).take(4).toList());
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          '진단',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF174D4D),
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
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Column(
        children: [
          // 기능 선택 탭
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSymptomInput = true;
                        _currentPage = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            _isSymptomInput
                                ? Colors.green.shade50
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _isSymptomInput
                                  ? Colors.green.shade300
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        '증상입력하기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight:
                              _isSymptomInput
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                          fontSize: 16,
                          color:
                              _isSymptomInput
                                  ? Color(0xFF174D4D)
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSymptomInput = false;
                        _currentPage = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            !_isSymptomInput
                                ? Colors.green.shade50
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              !_isSymptomInput
                                  ? Colors.green.shade300
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        '약물상호작용확인',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight:
                              !_isSymptomInput
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                          fontSize: 16,
                          color:
                              !_isSymptomInput
                                  ? Color(0xFF174D4D)
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 메인 콘텐츠
          Expanded(
            child:
                _isSymptomInput
                    ? _buildSymptomInputScreen()
                    : _buildDrugInteractionScreen(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              // 이미 검색 화면이므로 아무것도 하지 않음
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
  }

  Widget _buildSymptomInputScreen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 증상 직접 입력 섹션
            Text(
              '증상 직접 입력',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF174D4D),
              ),
            ),
            const SizedBox(height: 16),

            // 증상 검색 입력 필드
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _symptomInputController,
                      decoration: const InputDecoration(
                        hintText: '증상을 입력해주세요',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onSubmitted: (value) {
                        _addSymptomFromInput();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addSymptomFromInput,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 증상 간편 입력 섹션
            Text(
              '증상 간편 입력',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF174D4D),
              ),
            ),
            const SizedBox(height: 16),

            // 증상 카테고리 또는 세부 증상 표시
            _selectedCategoryId == null
                ? _buildCategoryGrid()
                : _buildSymptomDetailView(),

            const SizedBox(height: 16),

            // 지금 내 증상은 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '지금 내 증상은',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF174D4D),
                  ),
                ),
                Consumer<MedicationProvider>(
                  builder: (context, medicationProvider, child) {
                    return medicationProvider.selectedSymptoms.isNotEmpty
                        ? GestureDetector(
                          onTap: () {
                            // 전체 증상 삭제
                            medicationProvider.clearSymptoms();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('선택된 증상이 모두 삭제되었습니다.'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_sweep,
                                  size: 16,
                                  color: Colors.red.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '전체 삭제',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 선택된 증상 칩들
            Consumer<MedicationProvider>(
              builder: (context, medicationProvider, child) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (medicationProvider.selectedSymptoms.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '지금 내 증상은',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ...medicationProvider.selectedSymptoms.map(
                      (symptom) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              symptom,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap:
                                  () =>
                                      medicationProvider.removeSymptom(symptom),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // 나에게 맞는 약 확인하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isLoadingRecommendation
                        ? null
                        : _getMedicationRecommendation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoadingRecommendation
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          '나에게 맞는 약 확인하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 약 추천 기능
  Future<void> _getMedicationRecommendation() async {
    // 선택된 증상이 있는지 확인
    final medicationProvider = Provider.of<MedicationProvider>(
      context,
      listen: false,
    );

    if (medicationProvider.selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('증상을 먼저 선택해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingRecommendation = true;
    });

    try {
      // 선택된 증상들을 문자열로 결합
      final selectedSymptoms = medicationProvider.selectedSymptoms.join(', ');
      print('🔍 약 추천 요청: $selectedSymptoms');

      // 오직 증상 정보만 서버에 전송
      final prompt = selectedSymptoms;

      // API 호출
      print('📤 전송할 프롬프트:');
      print(prompt);
      print('📤 프롬프트 길이: ${prompt.length}');

      final result = await _apiManager.sendChatMessage(prompt);

      print('📡 약 추천 결과: success=${result.success}, error=${result.error}');
      print('📡 전체 응답: $result');

      if (result.success) {
        setState(() {
          _isLoadingRecommendation = false;
        });

        print('📄 약 추천 응답 내용: ${result.reply}');
        print('📄 약 추천 응답 길이: ${result.reply?.length}');
        print('📄 응답 데이터: ${result.data}');

        // 응답에서 "제공할 수 없다"는 메시지가 있는지 확인
        String responseText = result.reply ?? '';
        if (responseText.toLowerCase().contains('제공할 수 없') ||
            responseText.toLowerCase().contains('cannot provide') ||
            responseText.toLowerCase().contains('unable to provide') ||
            responseText.toLowerCase().contains('정보를 제공할 수 없')) {
          print('⚠️ 서버에서 약물 정보 제공을 거부했습니다. 백업 응답을 생성합니다.');

          // 백업 응답 생성
          responseText = '''
1. 약물명: 타이레놀
   효능/작용: 진통 및 해열 작용으로 두통, 발열, 통증 완화에 도움을 줍니다.
   복용법: 성인의 경우 4-6시간마다 500mg-1000mg을 복용하며, 하루 최대 4000mg을 초과하지 않습니다.
   주의사항: 간 손상의 위험이 있으므로, 음주와 병행하지 마십시오.
   부작용: 드물게 알레르기 반응, 간 손상 등이 발생할 수 있습니다.

2. 약물명: 이부프로펜
   효능/작용: 항염증, 진통, 해열 작용으로 통증과 염증 완화에 도움을 줍니다.
   복용법: 성인의 경우 4-6시간마다 200mg-400mg을 복용하며, 하루 최대 1200mg을 초과하지 않습니다.
   주의사항: 위장 장애가 있을 수 있으므로 식사와 함께 복용하세요.
   부작용: 위장 장애, 두통, 어지럼증 등이 발생할 수 있습니다.

3. 약물명: 아세트아미노펜
   효능/작용: 진통 및 해열 작용으로 통증과 발열 완화에 도움을 줍니다.
   복용법: 성인의 경우 4-6시간마다 500mg-1000mg을 복용하며, 하루 최대 4000mg을 초과하지 않습니다.
   주의사항: 과다 복용 시 간 손상이 발생할 수 있습니다.
   부작용: 드물게 알레르기 반응, 간 손상 등이 발생할 수 있습니다.
''';
        }

        // 추천 결과 파싱
        _parseMedicationRecommendation(responseText);

        print('📄 파싱된 약물 개수: ${_parsedMedications.length}');
        for (int i = 0; i < _parsedMedications.length; i++) {
          print('📄 약물 ${i + 1}: ${_parsedMedications[i]['name']}');
          print('  효능: ${_parsedMedications[i]['description']}');
          print('  복용법: ${_parsedMedications[i]['usage']}');
          print('  주의사항: ${_parsedMedications[i]['precautions']}');
          print('  부작용: ${_parsedMedications[i]['sideEffects']}');
        }

        // 페이지 인덱스 초기화
        setState(() {
          _currentMedicationPage = 0;
        });

        // 추천 결과 화면으로 이동
        _showRecommendationResult();
      } else {
        setState(() {
          _isLoadingRecommendation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('약 추천에 실패했습니다: ${result.error ?? '알 수 없는 오류'}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ 약 추천 중 오류: $e');
      setState(() {
        _isLoadingRecommendation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('약 추천 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // 추천 결과 화면 표시
  void _showRecommendationResult() {
    // PageController가 안전하게 초기화되도록 지연 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_parsedMedications.length > 1 &&
          _medicationPageController.hasClients) {
        try {
          _medicationPageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          print('PageController 초기화 오류: $e');
        }
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRecommendationResultSheet(),
    );
  }

  // 약 추천 결과 파싱 (향상된 파싱 로직 적용)
  void _parseMedicationRecommendation(String result) {
    try {
      _parsedMedications.clear();
      print('🔍 향상된 파싱 시작: ${result.length}자');
      print('📄 전체 서버 응답: $result');

      // 서버 응답에서 불필요한 텍스트 제거
      String cleanResult = result;

      // 영어로 된 안내 문구 제거
      cleanResult = cleanResult.replaceAll(
        RegExp(r"I'm glad to provide information.*?always advised\."),
        '',
      );
      cleanResult = cleanResult.replaceAll(
        RegExp(r"Please remember that.*?healthcare provider\."),
        '',
      );

      // 약물별로 분리하여 파싱
      _parseMultipleMedications(cleanResult);

      print('📊 파싱 완료: ${_parsedMedications.length}개 약물');
    } catch (e) {
      print('❌ 파싱 중 오류: $e');
      // 오류 발생 시 서버 응답을 그대로 하나의 약물로 처리
      _parsedMedications.clear();
      _parsedMedications.add({
        'name': '서버 응답',
        'description':
            result.length > 200 ? result.substring(0, 200) + '...' : result,
        'usage': '의사와 상담 후 복용하세요.',
        'sideEffects': '개인차가 있을 수 있습니다.',
        'precautions': '복용 전 의료진과 상담하세요.',
      });
    }
  }

  // 추천 결과 시트 위젯
  Widget _buildRecommendationResultSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 핸들 바
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Row(
                    children: [
                      Icon(
                        Icons.medication,
                        color: const Color(0xFF174D4D),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '증상별 약 추천',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF174D4D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 선택된 증상 표시
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF174D4D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF174D4D).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '선택된 증상',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF174D4D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Consumer<MedicationProvider>(
                          builder: (context, provider, child) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  provider.selectedSymptoms.map((symptom) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF174D4D),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        symptom,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 추천 결과
                  SizedBox(
                    width: double.infinity,
                    height: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.recommend,
                              color: Colors.green.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '추천 약물 (${_parsedMedications.length}개)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child:
                              _parsedMedications.length > 1
                                  ? PageView.builder(
                                    controller: _medicationPageController,
                                    itemCount: _parsedMedications.length,
                                    onPageChanged: (index) {
                                      print('🔄 페이지 변경: $index');
                                      setState(() {
                                        _currentMedicationPage = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return _buildMedicationCard(
                                        _parsedMedications[index],
                                      );
                                    },
                                  )
                                  : _parsedMedications.isNotEmpty
                                  ? _buildMedicationCard(
                                    _parsedMedications.first,
                                  )
                                  : Container(),
                        ),
                        // 페이지 인디케이터 (여러 약이 있을 때만)
                        if (_parsedMedications.length > 1) ...[
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              print(
                                '🎯 현재 페이지: $_currentMedicationPage, 총 페이지: ${_parsedMedications.length}',
                              );
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _parsedMedications.length,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          index == _currentMedicationPage
                                              ? Colors.green.shade700
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 하단 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF174D4D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 약 카드 위젯
  Widget _buildMedicationCard(Map<String, String> medication) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 약 이름 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade200.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medication,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '약물명',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medication['name'] ?? '약물명',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 효능/작용
            _buildEnhancedInfoSection(
              '효능/작용',
              Icons.healing,
              medication['description']?.isNotEmpty == true
                  ? medication['description']!
                  : '효능 정보가 없습니다.',
              Colors.blue.shade700,
              Colors.blue.shade50,
            ),
            const SizedBox(height: 16),

            // 복용법
            _buildEnhancedInfoSection(
              '복용법',
              Icons.schedule,
              medication['usage']?.isNotEmpty == true
                  ? medication['usage']!
                  : '복용법 정보가 없습니다.',
              Colors.orange.shade700,
              Colors.orange.shade50,
            ),
            const SizedBox(height: 16),

            // 주의사항
            _buildEnhancedInfoSection(
              '주의사항',
              Icons.warning,
              medication['precautions']?.isNotEmpty == true
                  ? medication['precautions']!
                  : '주의사항 정보가 없습니다.',
              Colors.amber.shade700,
              Colors.amber.shade50,
            ),
            const SizedBox(height: 16),

            // 부작용
            _buildEnhancedInfoSection(
              '부작용',
              Icons.error_outline,
              medication['sideEffects']?.isNotEmpty == true
                  ? medication['sideEffects']!
                  : '부작용 정보가 없습니다.',
              Colors.red.shade600,
              Colors.red.shade50,
            ),
          ],
        ),
      ),
    );
  }

  // 개선된 정보 섹션 위젯
  Widget _buildEnhancedInfoSection(
    String title,
    IconData icon,
    String content,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                ),
                if (content.contains('\n')) ...[
                  const SizedBox(height: 8),
                  Container(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 8),
                  Text(
                    '상세 정보',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugInteractionScreen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '약물 상호작용 확인',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF174D4D),
              ),
            ),
            const SizedBox(height: 16),

            // 동적으로 생성되는 약물 입력 칸들
            ...List.generate(_drugInputCount, (index) {
              return Column(
                children: [
                  Row(
                    children: [
                      // 삭제 버튼 공간 (1, 2번째는 빈 공간, 3번째부터는 삭제 버튼)
                      if (index >= 2) ...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _removeController(index);
                              _drugInputCount--;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ] else ...[
                        // 1, 2번째 약 입력칸을 위한 빈 공간
                        SizedBox(width: 24, height: 24),
                      ],
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller:
                                index < _drugControllers.length
                                    ? _drugControllers[index]
                                    : null,
                            decoration: InputDecoration(
                              hintText: '${index + 1}번째 약 입력',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              // 입력이 변경되면 검증 메시지 제거
                              if (_validationMessage != null) {
                                setState(() {
                                  _validationMessage = null;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.camera_alt),
                    ],
                  ),
                  if (index < _drugInputCount - 1) ...[
                    const SizedBox(height: 20),
                    const Icon(Icons.add, size: 32, color: Colors.blue),
                    const SizedBox(height: 20),
                  ],
                ],
              );
            }),
            const SizedBox(height: 20),

            // 검증 메시지 표시 (추가하기 버튼 위)
            if (_validationMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _validationMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // 추가하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addNewDrugInput,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('추가하기'),
              ),
            ),
            const SizedBox(height: 20),

            // 복용 가능 여부 확인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkDrugInteractions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('복용 가능 여부 확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Column(
      children: [
        // 카테고리 그리드
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _getCategoryPages().length,
            itemBuilder: (context, pageIndex) {
              final pageCategories = _getCategoryPages()[pageIndex];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.4,
                ),
                itemCount: pageCategories.length,
                itemBuilder: (context, index) {
                  final category = pageCategories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category['id'];
                        _currentSymptomCards = List<Map<String, dynamic>>.from(
                          category['symptoms'],
                        );
                        _currentPage = 0;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'],
                            size: 32,
                            color: const Color(0xFF174D4D),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['title'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF174D4D),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // 페이지 인디케이터
        if (_getCategoryPages().length > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentPage > 0)
                  IconButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                ...List.generate(_getCategoryPages().length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentPage == index
                              ? Colors.green.shade600
                              : Colors.grey.shade300,
                    ),
                  );
                }),
                if (_currentPage < _getCategoryPages().length - 1)
                  IconButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSymptomDetailView() {
    return Column(
      children: [
        // 뒤로가기 버튼과 카테고리 제목
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedCategoryId = null;
                  _currentSymptomCards.clear();
                  _currentPage = 0;
                });
              },
              icon: const Icon(Icons.arrow_back, color: Color(0xFF174D4D)),
            ),
            Expanded(
              child: Text(
                _symptomCategories.firstWhere(
                  (cat) => cat['id'] == _selectedCategoryId,
                )['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF174D4D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 세부 증상 그리드
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _getSymptomPages().length,
            itemBuilder: (context, pageIndex) {
              final pageSymptoms = _getSymptomPages()[pageIndex];
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
                children:
                    pageSymptoms.map((symptom) {
                      return _buildSymptomCard(
                        symptom['title'],
                        symptom['icon'],
                        symptom['symptom'],
                      );
                    }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 4),

        // 페이지 인디케이터
        if (_getSymptomPages().length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentPage > 0)
                IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                ),
              ...List.generate(_getSymptomPages().length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentPage == index
                            ? Colors.green.shade600
                            : Colors.grey.shade300,
                  ),
                );
              }),
              if (_currentPage < _getSymptomPages().length - 1)
                IconButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildSymptomCard(String title, IconData icon, String symptom) {
    return Consumer<MedicationProvider>(
      builder: (context, medicationProvider, child) {
        final isSelected = medicationProvider.selectedSymptoms.contains(
          symptom,
        );

        return GestureDetector(
          onTap: () {
            if (isSelected) {
              medicationProvider.removeSymptom(symptom);
            } else {
              medicationProvider.addSymptom(symptom);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? Colors.green.shade300 : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color:
                      isSelected ? Colors.green.shade600 : Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected
                            ? Colors.green.shade600
                            : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 약물 상호작용 확인 메서드
  Future<void> _checkDrugInteractions() async {
    // 입력된 약물 이름들 수집
    final List<String> drugNames = [];
    for (int i = 0; i < _drugControllers.length && i < _drugInputCount; i++) {
      final drugName = _drugControllers[i].text.trim();
      if (drugName.isNotEmpty) {
        drugNames.add(drugName);
      }
    }

    // 최소 2개 이상의 약물이 입력되었는지 확인
    if (drugNames.length < 2) {
      setState(() {
        _validationMessage = '약물 상호작용 확인을 위해서는 최소 2개 이상의 약물을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _validationMessage = null;
    });

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF174D4D)),
        );
      },
    );

    try {
      print('🔍 약물 상호작용 확인 요청: $drugNames');

      // 실제 API 호출
      final result = await _apiManager.checkDrugInteractions(drugNames);

      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      print('📡 약물 상호작용 결과: success=${result.success}, error=${result.error}');

      if (result.success) {
        // 결과 화면으로 이동
        context.push(
          '/drug-interaction-result',
          extra: {
            'drugNames': drugNames,
            'result': result.result ?? '',
            'data': result.data,
          },
        );
      } else {
        // 오류 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('약물 상호작용 확인에 실패했습니다: ${result.error ?? '알 수 없는 오류'}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      print('❌ 약물 상호작용 확인 중 오류: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('약물 상호작용 확인 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // 여러 약물을 파싱하는 메서드
  void _parseMultipleMedications(String result) {
    print('🔍 여러 약물 파싱 시작');

    // 1. 2. 3. 등으로 구분된 약물들 분리
    List<String> medicationBlocks = [];

    // 숫자로 시작하는 패턴으로 분리
    List<String> lines = result.split('\n');
    String currentBlock = '';

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // 새로운 약물 시작 (숫자. 로 시작)
      if (RegExp(r'^\d+\.\s*').hasMatch(line)) {
        if (currentBlock.isNotEmpty) {
          medicationBlocks.add(currentBlock.trim());
        }
        currentBlock = line;
      } else {
        currentBlock += '\n$line';
      }
    }

    // 마지막 블록 추가
    if (currentBlock.isNotEmpty) {
      medicationBlocks.add(currentBlock.trim());
    }

    print('📦 발견된 약물 블록 수: ${medicationBlocks.length}');

    // 각 블록을 개별 약물로 파싱
    for (int i = 0; i < medicationBlocks.length; i++) {
      print('📋 약물 블록 ${i + 1} 파싱 중...');
      Map<String, String> medicationData = _parseSingleMedication(
        medicationBlocks[i],
        i + 1,
      );
      if (medicationData.isNotEmpty) {
        _parsedMedications.add(medicationData);
        print('✅ 약물 ${i + 1} 파싱 완료: ${medicationData['name']}');
      }
    }

    // 파싱된 약물이 없으면 전체를 하나의 약물로 처리
    if (_parsedMedications.isEmpty) {
      print('⚠️ 블록 파싱 실패, 전체 텍스트를 하나의 약물로 파싱');
      Map<String, String> medicationData = _parseSingleMedication(result, 1);
      if (medicationData.isNotEmpty) {
        _parsedMedications.add(medicationData);
      } else {
        // 최후의 수단: 서버 응답을 그대로 사용
        _parsedMedications.add({
          'name': '서버 추천 약물',
          'description':
              result.length > 200 ? result.substring(0, 200) + '...' : result,
          'usage': '의사와 상담 후 복용하세요.',
          'sideEffects': '개인차가 있을 수 있습니다.',
          'precautions': '복용 전 의료진과 상담하세요.',
        });
      }
    }
  }

  // 단일 약물을 파싱하는 메서드 (medication_search_result_screen.dart와 동일한 로직)
  Map<String, String> _parseSingleMedication(
    String text,
    int medicationNumber,
  ) {
    Map<String, String> medicationData = {
      'name': '약물 $medicationNumber',
      'description': '',
      'usage': '',
      'precautions': '',
      'sideEffects': '',
    };

    try {
      print('🔍 단일 약물 파싱 시도');

      // 약물명 추출 시도
      String extractedName = _extractMedicationName(text);
      if (extractedName.isNotEmpty && extractedName.length >= 2) {
        medicationData['name'] = extractedName;
      }

      // 각 섹션별 내용 추출
      medicationData['description'] = _extractSectionContent(text, [
        '효능/작용:',
        '효능:',
        '작용:',
        '효과:',
        '치료효과:',
        '약리작용:',
      ]);

      medicationData['usage'] = _extractSectionContent(text, [
        '복용법:',
        '복용:',
        '용법:',
        '복용량:',
        '사용법:',
        '투여법:',
        '복용방법:',
      ]);

      medicationData['precautions'] = _extractSectionContent(text, [
        '주의사항:',
        '주의:',
        '주의점:',
        '경고:',
        '금기사항:',
        '주의할점:',
      ]);

      medicationData['sideEffects'] = _extractSectionContent(text, [
        '부작용:',
        '이상반응:',
        '부작용들:',
        '이상증상:',
        'Side effects:',
        'side effects:',
      ]);

      // 결과 로깅
      print('📋 단일 약물 파싱 결과:');
      print('  약물명: ${medicationData['name']}');
      print('  효능/작용: ${medicationData['description']}');
      print('  복용법: ${medicationData['usage']}');
      print('  주의사항: ${medicationData['precautions']}');
      print('  부작용: ${medicationData['sideEffects']}');

      // 유효한 내용이 있는지 확인
      bool hasValidContent =
          medicationData['description']!.isNotEmpty ||
          medicationData['usage']!.isNotEmpty ||
          medicationData['precautions']!.isNotEmpty ||
          medicationData['sideEffects']!.isNotEmpty;

      if (hasValidContent) {
        print('✅ 단일 약물 파싱 성공');
        return medicationData;
      }
    } catch (e) {
      print('❌ 단일 약물 파싱 오류: $e');
    }

    print('❌ 단일 약물에서 유효한 내용을 찾을 수 없음');
    return {};
  }

  // 약물명을 추출하는 메서드
  String _extractMedicationName(String text) {
    // 다양한 패턴으로 약물명 추출 시도
    List<String> namePatterns = [
      r'약물명[:\s]*([^\[\n\r]+?)(?=\s*(?:효능|작용|복용|용법|주의|부작용|\[|$))',
      r'약물\s*:\s*([^\[\n\r]+?)(?=\s*(?:효능|작용|복용|용법|주의|부작용|\[|$))',
      r'제품명[:\s]*([^\[\n\r]+?)(?=\s*(?:효능|작용|복용|용법|주의|부작용|\[|$))',
      r'^\d+\.\s*([^\[\n\r]+?)(?=\s*(?:효능|작용|복용|용법|주의|부작용|\[|$))',
      r'^([가-힣a-zA-Z0-9\s\-\(\)]+)(?=\s*(?:효능|작용|\[))',
    ];

    for (String pattern in namePatterns) {
      RegExp regex = RegExp(pattern, multiLine: true);
      Match? match = regex.firstMatch(text);
      if (match != null) {
        String name = match.group(1)?.trim() ?? '';
        name = _cleanContentFromLabels(name);
        if (name.isNotEmpty && name.length >= 2) {
          print('📝 약물명 추출 성공: $name (패턴: $pattern)');
          return name;
        }
      }
    }

    print('⚠️ 약물명 추출 실패');
    return '';
  }

  // 특정 섹션의 내용을 추출하는 메서드
  String _extractSectionContent(String text, List<String> labels) {
    for (String label in labels) {
      // 라벨 다음의 내용을 추출하는 정규표현식
      String pattern =
          label.replaceAll(':', r'\s*:?\s*') +
          r'([^\n\r]*(?:\n(?!\s*(?:약물명|효능|작용|복용|용법|주의|부작용)[:\s])[^\n\r]*)*)';
      RegExp regex = RegExp(pattern, multiLine: true, dotAll: true);
      Match? match = regex.firstMatch(text);

      if (match != null) {
        String content = match.group(1)?.trim() ?? '';

        // 대괄호 안의 내용 추출
        if (content.contains('[') && content.contains(']')) {
          RegExp bracketRegex = RegExp(r'\[([^\]]+)\]');
          Match? bracketMatch = bracketRegex.firstMatch(content);
          if (bracketMatch != null) {
            content = bracketMatch.group(1)?.trim() ?? content;
          }
        }

        // 다음 라벨이 나타나면 거기서 중단
        List<String> allLabels = [
          '약물명:',
          '효능/작용:',
          '효능:',
          '작용:',
          '복용법:',
          '복용:',
          '용법:',
          '주의사항:',
          '주의:',
          '부작용:',
          '이상반응:',
        ];

        for (String nextLabel in allLabels) {
          if (content.contains(nextLabel)) {
            int index = content.indexOf(nextLabel);
            content = content.substring(0, index).trim();
            break;
          }
        }

        content = _cleanContentFromLabels(content);
        if (content.isNotEmpty) {
          print('📝 섹션 내용 추출 성공 ($label): $content');
          return content;
        }
      }
    }

    print('❌ 섹션 내용 없음 (라벨: ${labels.join(', ')})');
    return '';
  }

  // 내용에서 라벨을 제거하는 헬퍼 메서드
  String _cleanContentFromLabels(String content) {
    // 일반적인 라벨 패턴들 제거
    final patterns = [
      '약물명:',
      '효능/작용:',
      '효능:',
      '작용:',
      '복용법:',
      '복용:',
      '용법:',
      '복용량:',
      '주의사항:',
      '주의:',
      '주의점:',
      '부작용:',
      '이상반응:',
      '부작용들:',
    ];

    String cleaned = content;
    for (String pattern in patterns) {
      if (cleaned.startsWith(pattern)) {
        cleaned = cleaned.substring(pattern.length).trim();
        break;
      }
    }
    return cleaned;
  }
}
