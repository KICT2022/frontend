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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          '검색',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '최근기록 | 타이레놀 화이투벤 콜드런',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 20),
                      // 기존 증상/약물 입력 탭, 결과 등은 여기에 그대로 배치
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isSymptomInput = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isSymptomInput
                                        ? Color(0xFF174D4D)
                                        : Colors.white,
                                foregroundColor:
                                    _isSymptomInput
                                        ? Colors.white
                                        : Colors.black,
                                side: const BorderSide(
                                  color: Color(0xFF174D4D),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('증상입력'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isSymptomInput = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    !_isSymptomInput
                                        ? Color(0xFF174D4D)
                                        : Colors.white,
                                foregroundColor:
                                    !_isSymptomInput
                                        ? Colors.white
                                        : Colors.black,
                                side: const BorderSide(
                                  color: Color(0xFF174D4D),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('약물 상호작용'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 기존 증상 입력/약물 상호작용 위젯
                      if (_isSymptomInput) _buildSymptomInput(),
                      if (!_isSymptomInput) _buildDrugInteraction(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildSymptomInput() {
    return Consumer<MedicationProvider>(
      builder: (context, medicationProvider, child) {
        return Column(
          children: [
            // 직접 입력
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: '직접입력',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.search),
              ],
            ),
            const SizedBox(height: 20),
            // 증상 목록
            SizedBox(
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _symptoms.length,
                itemBuilder: (context, index) {
                  final symptom = _symptoms[index];
                  final isSelected = medicationProvider.selectedSymptoms
                      .contains(symptom);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.yellow.shade100 : Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Text('->'),
                      title: Text(symptom),
                      onTap: () {
                        if (isSelected) {
                          medicationProvider.removeSymptom(symptom);
                        } else {
                          medicationProvider.addSymptom(symptom);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            // 선택된 증상 표시
            if (medicationProvider.selectedSymptoms.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  medicationProvider.selectedSymptoms.join(', '),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 자가 진단 시작
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('몸 자가 진단 시작'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDrugInteraction() {
    return Column(
      children: [
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
                        decoration: InputDecoration(
                          hintText: '${index + 1}번째 약 입력',
                          border: InputBorder.none,
                        ),
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
        // 추가하기 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _drugInputCount++;
              });
            },
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
    );
  }
}
