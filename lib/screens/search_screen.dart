import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../providers/notification_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isSymptomInput = true;
  List<String> _symptoms = [
    '머리가 아파요',
    '허리가 아파요',
    '심장이 아파요',
    '목이 아파요',
    '눈이 아파요',
  ];
  // 약물 입력 칸 개수를 관리하는 변수 추가
  int _drugInputCount = 2;
  // 약물 입력 칸들의 TextEditingController 리스트
  List<TextEditingController> _drugControllers = [];
  // 입력 검증 메시지
  String? _validationMessage;
  // 증상 입력 필드 컨트롤러
  TextEditingController _symptomInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    for (var controller in _drugControllers) {
      controller.dispose();
    }
    _symptomInputController.dispose();
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
                        '증상입력모드',
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
                        '약물상호작용모드',
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

            // 증상 아이콘 그리드
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildSymptomCard('두통', Icons.headset, '머리가 아파요'),
                _buildSymptomCard('인후통', Icons.record_voice_over, '목이 아파요'),
                _buildSymptomCard('요통', Icons.accessibility, '허리가 아파요'),
                _buildSymptomCard('흉통', Icons.favorite, '심장이 아파요'),
                _buildSymptomCard('복통', Icons.person, '배가 아파요'),
                _buildSymptomCard('관절통', Icons.accessibility_new, '관절이 아파요'),
                _buildSymptomCard('치통', Icons.face, '이가 아파요'),
                _buildSymptomCard('귀앓이', Icons.hearing, '귀가 아파요'),
                _buildSymptomCard('어깨통증', Icons.accessibility, '어깨가 아파요'),
                _buildSymptomCard('무릎통증', Icons.directions_walk, '무릎이 아파요'),
                _buildSymptomCard('손목통증', Icons.pan_tool, '손목이 아파요'),
                _buildSymptomCard('발목통증', Icons.directions_run, '발목이 아파요'),
              ],
            ),

            const SizedBox(height: 32),

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
                  // 나에게 맞는 약 확인 로직
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
                        Container(width: 24, height: 24),
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
