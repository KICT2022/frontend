import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../providers/notification_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';
import 'medication_detail_screen.dart';
import '../models/symptom.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isSymptomInput = true;
  final List<String> _selectedSymptoms = [];
  String? _selectedCategoryId;
  final TextEditingController _customSymptomController =
      TextEditingController();
  // 약물 입력 칸 개수를 관리하는 변수 추가
  int _drugInputCount = 2;
  // 약물 입력 칸들의 TextEditingController 리스트
  List<TextEditingController> _drugControllers = [];
  // 입력 검증 메시지
  String? _validationMessage;
  // 증상 입력 필드 컨트롤러
  TextEditingController _symptomInputController = TextEditingController();
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

  // 약물 데이터 (예시)
  final List<Map<String, dynamic>> _medications = [
    {
      'name': '타이레놀',
      'dosage': ['15세 이하 : 1알', '15세 이상 : 2알', '1일 2회'],
      'additionalInfo': '식후 30분에 복용하시고, 알코올과 함께 복용하지 마세요.',
    },
    {
      'name': '아스피린',
      'dosage': ['성인 : 1-2알', '1일 3-4회', '식후 복용'],
      'additionalInfo': '위장장애가 있을 수 있으니 주의하세요.',
    },
    {
      'name': '이부프로펜',
      'dosage': ['성인 : 1-2알', '1일 3-4회', '식사와 함께 복용'],
      'additionalInfo': '위장장애가 있을 수 있으니 주의하세요.',
    },
  ];

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
    _customSymptomController.dispose();
    _pageController.dispose();
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

  void _addSymptom(String symptomId) {
    setState(() {
      if (!_selectedSymptoms.contains(symptomId)) {
        _selectedSymptoms.add(symptomId);
      }
    });
  }

  void _removeSymptom(String symptomId) {
    setState(() {
      _selectedSymptoms.remove(symptomId);
    });
  }

  void _addCustomSymptom() {
    if (_customSymptomController.text.trim().isNotEmpty) {
      setState(() {
        _selectedSymptoms.add(_customSymptomController.text.trim());
        _customSymptomController.clear();
      });
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'general':
        return Icons.thermostat;
      case 'head_face':
        return Icons.face;
      case 'respiratory':
        return Icons.air;
      case 'digestive':
        return Icons.restaurant;
      case 'musculoskeletal':
        return Icons.accessibility;
      case 'skin':
        return Icons.brush;
      case 'urological':
        return Icons.wc;
      case 'neurological':
        return Icons.psychology;
      default:
        return Icons.medical_services;
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
            Text(
              '지금 내 증상은',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF174D4D),
              ),
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
                onPressed: () {
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

                  // 약물 상세 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MedicationDetailScreen(
                            medications: _medications,
                            userName: '홍길동', // 실제로는 사용자 정보에서 가져와야 함
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '나에게 맞는 약 확인하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
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
                onPressed: () {},
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
                          const SizedBox(height: 6),
                          Text(
                            category['title'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF174D4D),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            category['description'],
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${category['symptoms'].length}개 증상',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey.shade500,
                            ),
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
}
