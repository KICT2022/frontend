import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_manager.dart';

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
  String? _errorMessage;
  String? _drugInfo;

  // API 매니저 추가
  final ApiManager _apiManager = ApiManager();

  // 파싱된 약물 정보 저장
  final List<Map<String, String>> _parsedMedications = [];
  final PageController _medicationPageController = PageController();
  int _currentMedicationPage = 0;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void dispose() {
    _medicationPageController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _drugInfo = null;
    });

    try {
      print('🔍 약 검색 요청: ${widget.searchQuery}');

      // API를 통한 약 정보 검색
      final result = await _apiManager.getDrugInfo(widget.searchQuery);

      print('📡 약 검색 결과: success=${result.success}, error=${result.error}');

      if (result.success) {
        setState(() {
          _drugInfo = result.drugInfo;
          _isLoading = false;
        });

        // 서버 응답을 약물 카드 형식으로 파싱
        _parseDrugInfo(result.drugInfo ?? '');
      } else {
        setState(() {
          _errorMessage = result.error ?? '약 정보 검색에 실패했습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 약 검색 중 오류: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '검색 중 오류가 발생했습니다. 다시 시도해주세요.';
      });
    }
  }

  // 약물 정보 파싱 메서드 (search_screen.dart와 동일한 로직 사용)
  void _parseDrugInfo(String result) {
    try {
      _parsedMedications.clear();
      print('🔍 파싱 시작: ${result.length}자');
      print('📄 서버 응답: $result');

      // 대괄호 패턴으로 순차적 파싱 시도
      Map<String, String> medicationData = _parseBracketFormat(result);

      if (medicationData.isNotEmpty) {
        _parsedMedications.add(medicationData);
        print('✅ 대괄호 형식으로 파싱 완료');
      } else {
        // 대괄호 형식이 아닌 경우 기존 파싱 로직 사용
        _parseTraditionalFormat(result);
      }

      // 파싱된 약이 없으면 서버 응답을 그대로 하나의 약물로 처리
      if (_parsedMedications.isEmpty) {
        print('⚠️ 파싱된 약물이 없습니다. 서버 응답 전체를 하나의 약물로 처리합니다.');
        _parsedMedications.add({
          'name': widget.searchQuery,
          'description':
              result.length > 200 ? '${result.substring(0, 200)}...' : result,
          'usage': '의사와 상담 후 복용하세요.',
          'sideEffects': '개인차가 있을 수 있습니다.',
          'precautions': '복용 전 의료진과 상담하세요.',
        });
      }

      // 약물명이 비어있거나 너무 짧은 경우 보정
      for (int i = 0; i < _parsedMedications.length; i++) {
        if (_parsedMedications[i]['name']!.isEmpty ||
            _parsedMedications[i]['name']!.length < 2) {
          _parsedMedications[i]['name'] = widget.searchQuery;
          print('📝 약물명 보정: ${widget.searchQuery}');
        }

        // 빈 필드들을 기본값으로 채우기
        if (_parsedMedications[i]['description']!.isEmpty) {
          _parsedMedications[i]['description'] = '효능 정보를 확인할 수 없습니다.';
        }
        if (_parsedMedications[i]['usage']!.isEmpty) {
          _parsedMedications[i]['usage'] = '의사와 상담 후 복용하세요.';
        }
        if (_parsedMedications[i]['sideEffects']!.isEmpty) {
          _parsedMedications[i]['sideEffects'] = '개인차가 있을 수 있습니다.';
        }
        if (_parsedMedications[i]['precautions']!.isEmpty) {
          _parsedMedications[i]['precautions'] = '복용 전 의료진과 상담하세요.';
        }
      }

      // 페이지 인덱스 초기화
      setState(() {
        _currentMedicationPage = 0;
      });

      print('📊 파싱 완료: ${_parsedMedications.length}개 약물');
    } catch (e) {
      print('❌ 파싱 중 오류: $e');
      // 오류 발생 시 서버 응답을 그대로 하나의 약물로 처리
      _parsedMedications.clear();
      _parsedMedications.add({
        'name': widget.searchQuery,
        'description':
            result.length > 200 ? '${result.substring(0, 200)}...' : result,
        'usage': '의사와 상담 후 복용하세요.',
        'sideEffects': '개인차가 있을 수 있습니다.',
        'precautions': '복용 전 의료진과 상담하세요.',
      });
    }
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

    // 파싱된 약물 정보가 있는 경우 약물 카드 표시
    if (_parsedMedications.isNotEmpty) {
      return _buildMedicationCardsWidget();
    }

    // API 응답이 있는 경우 약 정보 표시 (백업용)
    if (_drugInfo != null && _drugInfo!.isNotEmpty) {
      return _buildDrugInfoWidget();
    }

    // 검색 결과가 없는 경우
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

  // 약물 카드들을 표시하는 위젯
  Widget _buildMedicationCardsWidget() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 약물 카드들
            SizedBox(
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                return _buildEnhancedMedicationCard(
                                  _parsedMedications[index],
                                );
                              },
                            )
                            : _parsedMedications.isNotEmpty
                            ? _buildEnhancedMedicationCard(
                              _parsedMedications.first,
                            )
                            : Container(),
                  ),
                  // 페이지 인디케이터 (여러 약이 있을 때만)
                  if (_parsedMedications.length > 1) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _parsedMedications.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                index == _currentMedicationPage
                                    ? Colors.green.shade700
                                    : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 다시 검색 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF174D4D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '다른 약 검색하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrugInfoWidget() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 약 정보 내용
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFF174D4D),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '약 정보',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF174D4D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _drugInfo!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 다시 검색 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF174D4D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '다른 약 검색하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget _buildMedicationCard(Medication medication) {
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
  }*/

  // 약 카드 위젯 (search_screen.dart와 동일한 디자인)
  Widget _buildEnhancedMedicationCard(Map<String, String> medication) {
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

  // 개선된 정보 섹션 위젯 (search_screen.dart와 동일한 디자인)
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

  // 특정 라벨들에서 내용을 추출하는 헬퍼 메서드
  String _extractContent(String line, List<String> labels) {
    for (String label in labels) {
      if (line.startsWith(label)) {
        return line.substring(label.length).trim();
      }
    }
    // 라벨이 없으면 전체 라인에서 공통 라벨들 제거
    return _cleanContentFromLabels(line);
  }

  // 약물명을 추출하는 메서드
  String _extractMedicationName(String text) {
    // 다양한 패턴으로 약물명 추출 시도
    List<String> namePatterns = [
      r'약물명[:\s]*([^\[\n\r]+?)(?=\s*(?:효능|작용|복용|용법|주의|부작용|\[|$))',
      r'약물\s*:\s*([^\[\n\r]+?)(?=\s*(?:효능|작용|복용|용법|주의|부작용|\[|$))',
      r'제품명[:\s]*([^\[\n\r]+?)(?=\s*(?:효능|작용|복용|용법|주의|부작용|\[|$))',
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

    print('⚠️ 약물명 추출 실패, 검색어 사용: ${widget.searchQuery}');
    return widget.searchQuery;
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

  // 향상된 파싱 메서드 (라벨 기반 + 대괄호 형식 지원)
  Map<String, String> _parseBracketFormat(String result) {
    Map<String, String> medicationData = {
      'name': widget.searchQuery,
      'description': '',
      'usage': '',
      'precautions': '',
      'sideEffects': '',
    };

    try {
      print('🔍 향상된 파싱 시도');
      print('📄 전체 서버 응답: $result');

      // 서버 응답에서 불필요한 텍스트 제거
      String cleanResult = result;
      cleanResult = cleanResult.replaceAll(
        RegExp(r"I'm glad to provide information.*?always advised\."),
        '',
      );
      cleanResult = cleanResult.replaceAll(
        RegExp(r"Please remember that.*?healthcare provider\."),
        '',
      );

      // 약물명 추출 시도
      String extractedName = _extractMedicationName(cleanResult);
      if (extractedName.isNotEmpty && extractedName.length >= 2) {
        medicationData['name'] = extractedName;
      }

      // 각 섹션별 내용 추출
      medicationData['description'] = _extractSectionContent(cleanResult, [
        '효능/작용:',
        '효능:',
        '작용:',
        '효과:',
        '치료효과:',
        '약리작용:',
      ]);

      medicationData['usage'] = _extractSectionContent(cleanResult, [
        '복용법:',
        '복용:',
        '용법:',
        '복용량:',
        '사용법:',
        '투여법:',
        '복용방법:',
      ]);

      medicationData['precautions'] = _extractSectionContent(cleanResult, [
        '주의사항:',
        '주의:',
        '주의점:',
        '경고:',
        '금기사항:',
        '주의할점:',
      ]);

      medicationData['sideEffects'] = _extractSectionContent(cleanResult, [
        '부작용:',
        '이상반응:',
        '부작용들:',
        '이상증상:',
        'Side effects:',
        'side effects:',
      ]);

      // 결과 로깅
      print('📋 파싱 결과:');
      print('  약물명: ${medicationData['name']}');
      print('  효능/작용: ${medicationData['description']}');
      print('  복용법: ${medicationData['usage']}');
      print('  주의사항: ${medicationData['precautions']}');
      print('  부작용: ${medicationData['sideEffects']}');

      // 모든 필드가 비어있지 않으면 성공으로 간주
      bool hasValidContent =
          medicationData['description']!.isNotEmpty ||
          medicationData['usage']!.isNotEmpty ||
          medicationData['precautions']!.isNotEmpty ||
          medicationData['sideEffects']!.isNotEmpty;

      if (hasValidContent) {
        print('✅ 파싱 성공');
        return medicationData;
      }
    } catch (e) {
      print('❌ 파싱 오류: $e');
    }

    print('❌ 유효한 내용을 찾을 수 없음');
    return {};
  }

  // 기존 형식으로 파싱하는 메서드 (백업용)
  void _parseTraditionalFormat(String result) {
    print('🔍 기존 형식으로 파싱');

    // 서버 응답에서 불필요한 텍스트 제거
    String cleanResult = result;
    cleanResult = cleanResult.replaceAll(
      RegExp(r"I'm glad to provide information.*?always advised\."),
      '',
    );
    cleanResult = cleanResult.replaceAll(
      RegExp(r"Please remember that.*?healthcare provider\."),
      '',
    );

    // 결과 텍스트를 줄바꿈으로 분리
    List<String> lines = cleanResult.split('\n');
    Map<String, String> currentMedication = {
      'name': widget.searchQuery,
      'description': '',
      'usage': '',
      'sideEffects': '',
      'precautions': '',
    };

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // 각 섹션별로 내용 분류
      if (line.contains('효능') ||
          line.contains('작용') ||
          line.startsWith('효능/작용:')) {
        String content = _extractContent(line, ['효능/작용:', '효능:', '작용:']);
        currentMedication['description'] = content;
      } else if (line.contains('복용') ||
          line.contains('용법') ||
          line.startsWith('복용법:')) {
        String content = _extractContent(line, ['복용법:', '복용:', '용법:', '복용량:']);
        currentMedication['usage'] = content;
      } else if (line.contains('주의') || line.startsWith('주의사항:')) {
        String content = _extractContent(line, ['주의사항:', '주의:', '주의점:']);
        currentMedication['precautions'] = content;
      } else if (line.contains('부작용') || line.startsWith('부작용:')) {
        String content = _extractContent(line, ['부작용:', '이상반응:', '부작용들:']);
        currentMedication['sideEffects'] = content;
      }
    }

    // 약물 정보 추가
    _parsedMedications.add(currentMedication);
  }
}
