import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isSymptomInput = true;
  List<String> _symptoms = [
    '머리가 아파요',
    '허리가 아파요',
    '심장이 아파요',
    '목이 아파요',
    '눈이 아파요',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 헤더
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: '약 통합 검색',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const Icon(Icons.search),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 최근 기록
              const Text(
                '최근기록 | 타이레놀 화이투벤 콜드런',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // 탭 버튼
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
                        backgroundColor: _isSymptomInput ? Colors.green : Colors.white,
                        foregroundColor: _isSymptomInput ? Colors.white : Colors.black,
                        side: BorderSide(color: Colors.black),
                      ),
                      child: const Text('증상입력'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isSymptomInput = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isSymptomInput ? Colors.green : Colors.white,
                        foregroundColor: !_isSymptomInput ? Colors.white : Colors.black,
                        side: BorderSide(color: Colors.black),
                      ),
                      child: const Text('약물간 상호작용'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 증상 입력 탭
              if (_isSymptomInput) _buildSymptomInput(),
              
              // 약물 상호작용 탭
              if (!_isSymptomInput) _buildDrugInteraction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomInput() {
    return Consumer<MedicationProvider>(
      builder: (context, medicationProvider, child) {
        return Expanded(
          child: Column(
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
              Expanded(
                child: ListView.builder(
                  itemCount: _symptoms.length,
                  itemBuilder: (context, index) {
                    final symptom = _symptoms[index];
                    final isSelected = medicationProvider.selectedSymptoms.contains(symptom);
                    
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
          ),
        );
      },
    );
  }

  Widget _buildDrugInteraction() {
    return Expanded(
      child: Column(
        children: [
          // 첫 번째 약 입력
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
                      hintText: '첫 번째 약 입력',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.camera_alt),
            ],
          ),
          const SizedBox(height: 20),

          // 플러스 아이콘
          const Icon(Icons.add, size: 32, color: Colors.blue),
          const SizedBox(height: 20),

          // 두 번째 약 입력
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
                      hintText: '두 번째 약 입력',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.camera_alt),
            ],
          ),
          const SizedBox(height: 20),

          // 추가하기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
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
    );
  }
} 