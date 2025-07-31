import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/medication.dart';

class MedicationSearchResultScreen extends StatefulWidget {
  final String searchQuery;

  const MedicationSearchResultScreen({super.key, required this.searchQuery});

  @override
  State<MedicationSearchResultScreen> createState() =>
      _MedicationSearchResultScreenState();
}

class _MedicationSearchResultScreenState
    extends State<MedicationSearchResultScreen> {
  bool _isLoading = true;
  List<Medication> _searchResults = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 백엔드 API 호출 시뮬레이션 (실제로는 API 호출)
      await Future.delayed(const Duration(seconds: 1));

      // 임시 더미 데이터
      _searchResults = _getDummySearchResults(widget.searchQuery);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '검색 중 오류가 발생했습니다. 다시 시도해주세요.';
      });
    }
  }

  List<Medication> _getDummySearchResults(String query) {
    // 임시 더미 데이터 - 실제로는 백엔드에서 받아올 데이터
    final dummyData = [
      {
        'id': '1',
        'name': '타이레놀 500mg',
        'genericName': '아세트아미노펜',
        'manufacturer': '한국얀센',
        'description': '해열, 진통제로 사용되는 약물입니다.',
        'indications': '두통, 치통, 생리통, 근육통, 관절통, 감기로 인한 발열 및 통증',
        'dosage': '성인: 1회 1-2정, 1일 3-4회 복용',
        'precautions': '간장애 환자, 알코올 중독자, 알레르기 환자는 주의',
        'sideEffects': '구역, 구토, 복통, 발진 등',
        'imageUrl': null,
      },
      {
        'id': '2',
        'name': '아스피린 100mg',
        'genericName': '아세틸살리실산',
        'manufacturer': '바이엘',
        'description': '해열, 진통, 항염증 작용을 하는 약물입니다.',
        'indications': '두통, 치통, 생리통, 근육통, 관절통, 감기로 인한 발열 및 통증',
        'dosage': '성인: 1회 1-2정, 1일 3-4회 복용',
        'precautions': '위궤양 환자, 출혈성 질환자, 임신부는 주의',
        'sideEffects': '위장장애, 출혈, 알레르기 반응 등',
        'imageUrl': null,
      },
      {
        'id': '3',
        'name': '판콜에이 정',
        'genericName': '아세트아미노펜, 클로르페니라민말레산염, 슈도에페드린염산염',
        'manufacturer': '동아제약',
        'description': '감기 증상 완화를 위한 복합제입니다.',
        'indications': '감기로 인한 발열, 오한, 두통, 콧물, 코막힘, 재채기, 인후통',
        'dosage': '성인: 1회 2정, 1일 3회 복용',
        'precautions': '고혈압, 심장질환, 갑상선질환, 당뇨병 환자는 주의',
        'sideEffects': '졸음, 어지러움, 구역, 구토, 식욕부진 등',
        'imageUrl': null,
      },
    ];

    // 검색어에 따른 필터링 (실제로는 백엔드에서 처리)
    return dummyData
        .where(
          (med) =>
              med['name']!.toLowerCase().contains(query.toLowerCase()) ||
              med['genericName']!.toLowerCase().contains(query.toLowerCase()),
        )
        .map((data) => Medication.fromMap(data))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          '"${widget.searchQuery}" 검색 결과',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF174D4D),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF174D4D)),
          onPressed: () => context.pop(),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF174D4D)),
            ),
            SizedBox(height: 16),
            Text(
              '약 정보를 검색하고 있습니다...',
              style: TextStyle(fontSize: 16, color: Color(0xFF174D4D)),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF174D4D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '"${widget.searchQuery}"에 대한 검색 결과가 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '다른 검색어를 입력해보세요.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '검색 결과 ${_searchResults.length}건',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF174D4D),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final medication = _searchResults[index];
                return _buildMedicationCard(medication);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: () => _showMedicationDetail(medication),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF174D4D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medication,
                      size: 30,
                      color: Color(0xFF174D4D),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF174D4D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (medication.genericName != null)
                          Text(
                            medication.genericName!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        if (medication.genericName != null)
                          const SizedBox(height: 4),
                        if (medication.manufacturer != null)
                          Text(
                            medication.manufacturer!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF174D4D),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                medication.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF174D4D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '복용법',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF174D4D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      medication.dosage,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMedicationDetail(Medication medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMedicationDetailSheet(medication),
    );
  }

  Widget _buildMedicationDetailSheet(Medication medication) {
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
                  // 약 이름과 기본 정보
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF174D4D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.medication,
                          size: 40,
                          color: Color(0xFF174D4D),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF174D4D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (medication.genericName != null)
                              Text(
                                medication.genericName!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (medication.genericName != null)
                              const SizedBox(height: 4),
                            if (medication.manufacturer != null)
                              Text(
                                medication.manufacturer!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 설명
                  _buildDetailSection(
                    '약물 설명',
                    medication.description,
                    Icons.info_outline,
                  ),
                  const SizedBox(height: 24),

                  // 적응증
                  if (medication.indications != null)
                    _buildDetailSection(
                      '적응증',
                      medication.indications!,
                      Icons.healing,
                    ),
                  if (medication.indications != null)
                    const SizedBox(height: 24),

                  // 복용법
                  _buildDetailSection('복용법', medication.dosage, Icons.schedule),
                  const SizedBox(height: 24),

                  // 주의사항
                  if (medication.precautions != null)
                    _buildDetailSection(
                      '주의사항',
                      medication.precautions!,
                      Icons.warning_amber,
                      isWarning: true,
                    ),
                  const SizedBox(height: 24),

                  // 부작용
                  _buildDetailSection(
                    '부작용',
                    medication.sideEffects.join(', '),
                    Icons.error_outline,
                    isWarning: true,
                  ),
                  const SizedBox(height: 32),

                  // 하단 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 약을 내 약통에 추가하는 기능 (추후 구현)
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('약이 내 약통에 추가되었습니다.'),
                            backgroundColor: Color(0xFF174D4D),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF174D4D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '내 약통에 추가',
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
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String content,
    IconData icon, {
    bool isWarning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  isWarning ? Colors.orange.shade600 : const Color(0xFF174D4D),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isWarning
                        ? Colors.orange.shade600
                        : const Color(0xFF174D4D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isWarning
                    ? Colors.orange.shade50
                    : const Color(0xFF174D4D).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isWarning
                      ? Colors.orange.shade200
                      : const Color(0xFF174D4D).withOpacity(0.1),
            ),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
