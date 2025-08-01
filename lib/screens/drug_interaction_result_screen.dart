import 'package:flutter/material.dart';

class DrugInteractionResultScreen extends StatelessWidget {
  final List<String> drugNames;
  final String result;
  final Map<String, dynamic>? data;

  const DrugInteractionResultScreen({
    super.key,
    required this.drugNames,
    required this.result,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          '약물 상호작용 결과',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF174D4D),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFF174D4D)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검사한 약물 목록
            _buildDrugListCard(),
            const SizedBox(height: 20),

            // 서버 응답 결과
            _buildServerResponseCard(),
            const SizedBox(height: 20),

            // 상세 상호작용 정보 (데이터가 있는 경우)
            if (data != null && data!['interactions'] != null) ...[
              _buildDetailedInteractionsCard(),
              const SizedBox(height: 20),
            ],

            // 권장사항 (데이터가 있는 경우)
            if (data != null && data!['recommendations'] != null) ...[
              _buildRecommendationsCard(),
              const SizedBox(height: 20),
            ],

            // 주의사항
            _buildWarningCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrugListCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  Icons.medication,
                  size: 24,
                  color: const Color(0xFF174D4D),
                ),
                const SizedBox(width: 12),
                const Text(
                  '검사한 약물',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF174D4D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...drugNames.asMap().entries.map((entry) {
              final index = entry.key;
              final drugName = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF174D4D).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF174D4D),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        drugName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /*Widget _buildSummaryCard() {
    final severity = data?['severity'] ?? 'unknown';
    final isSafe = data?['isSafe'] ?? false;

    Color cardColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    if (isSafe) {
      cardColor = Colors.green.shade50;
      statusIcon = Icons.check_circle;
      statusText = '복용 가능';
      statusDescription = '검사한 약물들 간에 심각한 상호작용이 없습니다.';
    } else {
      switch (severity.toLowerCase()) {
        case 'high':
          cardColor = Colors.red.shade50;
          statusIcon = Icons.warning;
          statusText = '복용 금기';
          statusDescription = '심각한 상호작용이 있어 복용을 금합니다.';
          break;
        case 'moderate':
          cardColor = Colors.orange.shade50;
          statusIcon = Icons.warning_amber;
          statusText = '주의 필요';
          statusDescription = '상호작용이 있어 주의가 필요합니다.';
          break;
        case 'low':
          cardColor = Colors.yellow.shade50;
          statusIcon = Icons.info;
          statusText = '경미한 상호작용';
          statusDescription = '경미한 상호작용이 있을 수 있습니다.';
          break;
        default:
          cardColor = Colors.grey.shade50;
          statusIcon = Icons.help;
          statusText = '확인 필요';
          statusDescription = '상호작용 정보를 확인할 수 없습니다.';
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  size: 32,
                  color:
                      isSafe ? Colors.green.shade600 : Colors.orange.shade600,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              isSafe
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isSafe
                                  ? Colors.green.shade600
                                  : Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }*/

  Widget _buildDetailedInteractionsCard() {
    final interactions = data?['interactions'] as List<dynamic>? ?? [];

    if (interactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, size: 24, color: const Color(0xFF174D4D)),
                const SizedBox(width: 12),
                const Text(
                  '상세 상호작용 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF174D4D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...interactions.map((interaction) {
              final severity = interaction['severity'] ?? 'unknown';
              final description = interaction['description'] ?? '';
              final drugs = interaction['drugs'] ?? [];

              Color severityColor;
              IconData severityIcon;
              String severityText;

              switch (severity.toLowerCase()) {
                case 'high':
                  severityColor = Colors.red;
                  severityIcon = Icons.warning;
                  severityText = '심각';
                  break;
                case 'moderate':
                  severityColor = Colors.orange;
                  severityIcon = Icons.warning_amber;
                  severityText = '보통';
                  break;
                case 'low':
                  severityColor = Colors.yellow.shade700;
                  severityIcon = Icons.info;
                  severityText = '경미';
                  break;
                default:
                  severityColor = Colors.grey;
                  severityIcon = Icons.help;
                  severityText = '알 수 없음';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: severityColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(severityIcon, color: severityColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '상호작용 수준: $severityText',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: severityColor,
                          ),
                        ),
                      ],
                    ),
                    if (drugs.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '관련 약물: ${drugs.join(', ')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    final recommendations = data?['recommendations'] as List<dynamic>? ?? [];

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, size: 24, color: const Color(0xFF174D4D)),
                const SizedBox(width: 12),
                const Text(
                  '권장사항',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF174D4D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value as String;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF174D4D).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF174D4D),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '이 결과는 참고용이며, 실제 복용 전 반드시 의사나 약사와 상담하세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerResponseCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  Icons.check_circle_outline,
                  size: 24,
                  color: const Color(0xFF174D4D),
                ),
                const SizedBox(width: 12),
                const Text(
                  '상호작용 분석 결과',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF174D4D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                result.isNotEmpty ? result : '서버 응답이 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
