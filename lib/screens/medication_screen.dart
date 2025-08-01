import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../providers/reminder_provider.dart';

import '../widgets/bottom_navigation.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          '복약',
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
                      Row(
                        children: [
                          Icon(
                            Icons.medication,
                            size: 40,
                            color: Color(0xFF174D4D),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            '오늘의 약, 잊지 마세요.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF174D4D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildMedicationSchedule(),
                      const SizedBox(height: 20),
                      // 오늘의 복용 완료 체크
                      _buildTodayCompletionSection(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                        '복약 일정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF174D4D),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer<ReminderProvider>(
                        builder: (context, reminderProvider, child) {
                          return Column(
                            children:
                                reminderProvider.reminders
                                    .map(
                                      (reminder) =>
                                          _buildReminderItem(reminder),
                                    )
                                    .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showAddReminderDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF174D4D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('일정 추가하기'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 주간 복용 달성률
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
                            Icons.trending_up,
                            size: 28,
                            color: Color(0xFFFFD700),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '월간 복용 달성률',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF174D4D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 월간 달성률 스탬프 그리드
                      _buildMonthlyAchievementGrid(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              // 이미 약물 화면이므로 아무것도 하지 않음
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }

  // 요일을 한국어로 변환
  String _getKoreanWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return '월';
    }
  }

  // 시간을 시간대별로 분류
  String _getTimeOfDay(String time) {
    final hour = int.parse(time.split(':')[0]);
    if (hour >= 5 && hour < 11) return '아침';
    if (hour >= 11 && hour < 17) return '점심';
    return '저녁';
  }

  // 헤더용 시간대 슬롯을 만드는 메서드
  Widget _buildHeaderTimeSlot(String timeLabel, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(_getTimeIcon(timeLabel), size: 14, color: color),
            const SizedBox(height: 2),
            Text(
              timeLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 시간대별 아이콘을 반환하는 메서드
  IconData _getTimeIcon(String timeLabel) {
    switch (timeLabel) {
      case '아침':
        return Icons.wb_sunny;
      case '점심':
        return Icons.restaurant;
      case '저녁':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }

  Widget _buildMedicationSchedule() {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        if (reminderProvider.reminders.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  '오늘 복용할 약이 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '복약 알림을 설정해보세요!',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // 테이블 헤더
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(
                            Icons.medication,
                            size: 20,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '약 이름',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          _buildHeaderTimeSlot('아침', Colors.orange),
                          const SizedBox(width: 8),
                          _buildHeaderTimeSlot('점심', Colors.green),
                          const SizedBox(width: 8),
                          _buildHeaderTimeSlot('저녁', Colors.purple),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 알림들을 약별로 그룹화해서 표시
              ...reminderProvider.reminders.map(
                (reminder) => _buildMedicationRowFromReminder(reminder),
              ),
            ],
          ),
        );
      },
    );
  }

  // 알림 데이터로부터 약 행을 만드는 메서드
  Widget _buildMedicationRowFromReminder(Map<String, dynamic> reminder) {
    final textParts = reminder['text'].split(' • ');
    final medicationName = textParts.isNotEmpty ? textParts[0] : '';
    final note = textParts.length > 3 ? textParts[3] : '';
    final reminderId = reminder['id'];

    // 시간들을 파싱해서 시간대별로 분류
    final times = _parseTimesFromText(reminder['text']);
    bool hasMorning = false;
    bool hasLunch = false;
    bool hasEvening = false;

    for (final time in times) {
      final timeOfDay = _getTimeOfDay(
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      );
      if (timeOfDay == '아침') hasMorning = true;
      if (timeOfDay == '점심') hasLunch = true;
      if (timeOfDay == '저녁') hasEvening = true;
    }

    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // 약 이름과 아이콘
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.medication,
                        size: 20,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicationName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (note.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              note,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // 시간대별 표시
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    _buildClickableTimeSlot(
                      '아침',
                      hasMorning,
                      Colors.orange,
                      reminderId,
                      reminderProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildClickableTimeSlot(
                      '점심',
                      hasLunch,
                      Colors.green,
                      reminderId,
                      reminderProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildClickableTimeSlot(
                      '저녁',
                      hasEvening,
                      Colors.purple,
                      reminderId,
                      reminderProvider,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 클릭 가능한 시간대별 슬롯을 만드는 메서드
  Widget _buildClickableTimeSlot(
    String timeLabel,
    bool hasSchedule,
    Color activeColor,
    int reminderId,
    ReminderProvider reminderProvider,
  ) {
    final isCompleted = reminderProvider.isCompleted(reminderId, timeLabel);
    final isEnabled = hasSchedule; // 해당 시간대에 알림이 설정되어 있을 때만 활성화

    return Expanded(
      child: GestureDetector(
        onTap:
            isEnabled
                ? () {
                  reminderProvider.toggleCompletion(reminderId, timeLabel);
                }
                : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color:
                !isEnabled
                    ? Colors.grey.shade50
                    : isCompleted
                    ? activeColor.withOpacity(0.2)
                    : activeColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
                  !isEnabled
                      ? Colors.grey.shade200
                      : isCompleted
                      ? activeColor
                      : activeColor.withOpacity(0.3),
              width: isCompleted ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle
                    : isEnabled
                    ? Icons.circle_outlined
                    : Icons.remove_circle_outline,
                size: 16,
                color:
                    !isEnabled
                        ? Colors.grey.shade400
                        : isCompleted
                        ? activeColor
                        : activeColor.withOpacity(0.6),
              ),
              const SizedBox(height: 4),
              Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color:
                      !isEnabled
                          ? Colors.grey.shade500
                          : isCompleted
                          ? activeColor
                          : activeColor.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderItem(Map<String, dynamic> reminder) {
    final textParts = reminder['text'].split(' • ');
    final medicationName = textParts.isNotEmpty ? textParts[0] : '';
    final daysText = textParts.length > 1 ? textParts[1] : '';
    final timeText = textParts.length > 2 ? textParts[2] : '';
    final noteText = textParts.length > 3 ? textParts[3] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF174D4D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medication,
                  size: 20,
                  color: Color(0xFF174D4D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicationName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF174D4D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          daysText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (noteText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              noteText,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue.shade700, size: 18),
                  onPressed: () => _showAddReminderDialog(reminder),
                  tooltip: '수정',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade700,
                    size: 18,
                  ),
                  onPressed: () => _showDeleteConfirmDialog(reminder['id']),
                  tooltip: '삭제',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 알림 추가/수정 다이얼로그를 보여주는 메서드
  void _showAddReminderDialog([Map<String, dynamic>? existingReminder]) {
    bool isEditing = existingReminder != null;
    String medicationName = '';
    List<TimeOfDay> selectedTimes = [TimeOfDay.now()];
    List<String> selectedDays = [];
    String medicationNote = '';

    // 수정 모드일 때 기존 데이터 설정
    if (isEditing) {
      final textParts = existingReminder['text'].split(' • ');
      if (textParts.isNotEmpty) {
        // 약 이름 추출 (첫 번째 부분에서 약 이름만 추출)
        medicationName = textParts[0];
      }
      selectedTimes = _parseTimesFromText(existingReminder['text']);
      selectedDays = List<String>.from(existingReminder['days']);
      if (textParts.length > 3) {
        medicationNote = textParts[3];
      }
    }

    // TextEditingController 생성
    final TextEditingController medicationNameController =
        TextEditingController(text: medicationName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEditing ? '일정 수정하기' : '일정 추가하기',
                style: TextStyle(
                  color: Color(0xFF174D4D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 약 이름 입력
                    TextField(
                      controller: medicationNameController,
                      decoration: InputDecoration(
                        labelText: '약 이름',
                        hintText: '예: A약, B약',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        medicationName = value;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 시간 선택
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '시간 선택',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedTimes.add(TimeOfDay.now());
                            });
                          },
                          icon: Icon(Icons.add, size: 16),
                          label: Text('시간 추가'),
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFF174D4D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 선택된 시간들 표시
                    ...selectedTimes.asMap().entries.map((entry) {
                      int index = entry.key;
                      TimeOfDay time = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  // 시간 선택
                                  Expanded(
                                    child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: ListWheelScrollView.useDelegate(
                                        itemExtent: 40,
                                        physics: FixedExtentScrollPhysics(),
                                        controller: FixedExtentScrollController(
                                          initialItem: time.hour,
                                        ),
                                        onSelectedItemChanged: (value) {
                                          setState(() {
                                            selectedTimes[index] = TimeOfDay(
                                              hour: value,
                                              minute: time.minute,
                                            );
                                          });
                                        },
                                        childDelegate:
                                            ListWheelChildBuilderDelegate(
                                              builder: (context, index) {
                                                if (index < 0 || index > 23)
                                                  return null;
                                                return Center(
                                                  child: Text(
                                                    index.toString().padLeft(
                                                      2,
                                                      '0',
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              },
                                              childCount: 24,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      ':',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // 분 선택
                                  Expanded(
                                    child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: ListWheelScrollView.useDelegate(
                                        itemExtent: 40,
                                        physics: FixedExtentScrollPhysics(),
                                        controller: FixedExtentScrollController(
                                          initialItem: time.minute,
                                        ),
                                        onSelectedItemChanged: (value) {
                                          setState(() {
                                            selectedTimes[index] = TimeOfDay(
                                              hour: time.hour,
                                              minute: value,
                                            );
                                          });
                                        },
                                        childDelegate:
                                            ListWheelChildBuilderDelegate(
                                              builder: (context, index) {
                                                if (index < 0 || index > 59)
                                                  return null;
                                                return Center(
                                                  child: Text(
                                                    index.toString().padLeft(
                                                      2,
                                                      '0',
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              },
                                              childCount: 60,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedTimes.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedTimes.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                    // 빠른 시간 선택 버튼들
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickTimeButton(
                          '아침',
                          TimeOfDay(hour: 8, minute: 0),
                          selectedTimes.isNotEmpty
                              ? selectedTimes.last
                              : TimeOfDay.now(),
                          () {
                            setState(() {
                              if (selectedTimes.isNotEmpty) {
                                selectedTimes[selectedTimes.length -
                                    1] = TimeOfDay(hour: 8, minute: 0);
                              }
                            });
                          },
                        ),
                        _buildQuickTimeButton(
                          '점심',
                          TimeOfDay(hour: 12, minute: 0),
                          selectedTimes.isNotEmpty
                              ? selectedTimes.last
                              : TimeOfDay.now(),
                          () {
                            setState(() {
                              if (selectedTimes.isNotEmpty) {
                                selectedTimes[selectedTimes.length -
                                    1] = TimeOfDay(hour: 12, minute: 0);
                              }
                            });
                          },
                        ),
                        _buildQuickTimeButton(
                          '저녁',
                          TimeOfDay(hour: 18, minute: 0),
                          selectedTimes.isNotEmpty
                              ? selectedTimes.last
                              : TimeOfDay.now(),
                          () {
                            setState(() {
                              if (selectedTimes.isNotEmpty) {
                                selectedTimes[selectedTimes.length -
                                    1] = TimeOfDay(hour: 18, minute: 0);
                              }
                            });
                          },
                        ),
                        _buildQuickTimeButton(
                          '취침',
                          TimeOfDay(hour: 22, minute: 0),
                          selectedTimes.isNotEmpty
                              ? selectedTimes.last
                              : TimeOfDay.now(),
                          () {
                            setState(() {
                              if (selectedTimes.isNotEmpty) {
                                selectedTimes[selectedTimes.length -
                                    1] = TimeOfDay(hour: 22, minute: 0);
                              }
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 요일 선택
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '요일 선택',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (selectedDays.length == 7) {
                                // 모든 요일이 선택되어 있으면 전체 해제
                                selectedDays.clear();
                              } else {
                                // 모든 요일 선택
                                selectedDays.clear();
                                selectedDays.addAll([
                                  '월',
                                  '화',
                                  '수',
                                  '목',
                                  '금',
                                  '토',
                                  '일',
                                ]);
                              }
                            });
                          },
                          child: Text(
                            selectedDays.length == 7 ? '전체 해제' : '전체 선택',
                            style: TextStyle(
                              color: Color(0xFF174D4D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          ['월', '화', '수', '목', '금', '토', '일'].map((day) {
                            bool isSelected = selectedDays.contains(day);
                            return FilterChip(
                              label: Text(day),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedDays.add(day);
                                  } else {
                                    selectedDays.remove(day);
                                  }
                                });
                              },
                              selectedColor: Color(0xFF174D4D).withOpacity(0.3),
                              checkmarkColor: Color(0xFF174D4D),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final currentMedicationName =
                        medicationNameController.text.trim();
                    if (currentMedicationName.isNotEmpty &&
                        selectedDays.isNotEmpty &&
                        selectedTimes.isNotEmpty) {
                      if (isEditing) {
                        _updateReminder(
                          existingReminder['id'],
                          currentMedicationName,
                          selectedTimes,
                          selectedDays,
                          medicationNote,
                        );
                      } else {
                        _addReminder(
                          currentMedicationName,
                          selectedTimes,
                          selectedDays,
                          medicationNote,
                        );
                      }
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('약 이름, 요일, 시간을 모두 입력해주세요.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF174D4D),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEditing ? '수정' : '추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 새로운 알림을 추가하는 메서드
  void _addReminder(
    String medicationName,
    List<TimeOfDay> times,
    List<String> days,
    String note,
  ) {
    final timeStrings =
        times
            .map(
              (time) =>
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            )
            .toList();
    final timeString = timeStrings.join(', ');

    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );
    reminderProvider.addReminder(medicationName, timeString, days, note);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('알림이 추가되었습니다.'), backgroundColor: Colors.green),
    );
  }

  // 삭제 확인 다이얼로그를 보여주는 메서드
  void _showDeleteConfirmDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade600, size: 24),
              const SizedBox(width: 8),
              Text(
                '일정 삭제',
                style: TextStyle(
                  color: Color(0xFF174D4D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            '이 복약 일정을 삭제하시겠습니까?\n삭제된 일정은 복구할 수 없습니다.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReminder(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  // 알림을 삭제하는 메서드
  void _deleteReminder(int id) {
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );
    reminderProvider.deleteReminder(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('일정이 삭제되었습니다.'),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // 텍스트에서 시간들을 파싱하는 메서드
  List<TimeOfDay> _parseTimesFromText(String text) {
    // "C약 • 매일 • 14:00, 18:00" 형태에서 시간들 추출
    final timeRegex = RegExp(r'(\d{1,2}):(\d{2})');
    final matches = timeRegex.allMatches(text);
    List<TimeOfDay> times = [];

    for (final match in matches) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      times.add(TimeOfDay(hour: hour, minute: minute));
    }

    return times.isNotEmpty ? times : [TimeOfDay.now()];
  }

  // 알림을 수정하는 메서드
  void _updateReminder(
    int id,
    String medicationName,
    List<TimeOfDay> times,
    List<String> days,
    String note,
  ) {
    final timeStrings =
        times
            .map(
              (time) =>
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            )
            .toList();
    final timeString = timeStrings.join(', ');

    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );
    reminderProvider.updateReminder(id, medicationName, timeString, days, note);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('알림이 수정되었습니다.'), backgroundColor: Colors.green),
    );
  }

  Widget _buildQuickTimeButton(
    String label,
    TimeOfDay time,
    TimeOfDay selectedTime,
    GestureTapCallback onTap,
  ) {
    bool isSelected =
        selectedTime.hour == time.hour && selectedTime.minute == time.minute;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF174D4D) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF174D4D) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 오늘의 복용 완료 섹션을 만드는 메서드
  Widget _buildTodayCompletionSection() {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        if (reminderProvider.reminders.isEmpty) {
          return SizedBox.shrink(); // 알림이 없으면 아무것도 표시하지 않음
        }

        // 오늘 복용해야 하는 모든 시간대를 계산
        int totalRequiredDoses = 0;
        int completedDoses = 0;

        for (final reminder in reminderProvider.reminders) {
          final times = _parseTimesFromText(reminder['text']);
          final today = DateTime.now();
          final todayWeekday = _getKoreanWeekday(today.weekday);
          final days = List<String>.from(reminder['days']);

          if (days.contains(todayWeekday)) {
            for (final time in times) {
              final timeOfDay = _getTimeOfDay(
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              );
              totalRequiredDoses++;
              if (reminderProvider.isCompleted(reminder['id'], timeOfDay)) {
                completedDoses++;
              }
            }
          }
        }

        final bool isAllCompleted =
            totalRequiredDoses > 0 && completedDoses == totalRequiredDoses;
        final double completionRate =
            totalRequiredDoses > 0 ? completedDoses / totalRequiredDoses : 0.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAllCompleted ? Colors.green.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isAllCompleted ? Colors.green.shade200 : Colors.blue.shade200,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAllCompleted ? Icons.check_circle : Icons.medication,
                    size: 24,
                    color:
                        isAllCompleted
                            ? Colors.green.shade600
                            : Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAllCompleted ? '오늘 복용 완료!' : '오늘의 복용 현황',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isAllCompleted
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 진행률 표시
              if (totalRequiredDoses > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$completedDoses/$totalRequiredDoses 복용',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isAllCompleted
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '(${(completionRate * 100).toInt()}%)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isAllCompleted
                                ? Colors.green.shade600
                                : Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 진행률 바
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: completionRate,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isAllCompleted
                                ? Colors.green.shade500
                                : Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                isAllCompleted
                    ? '오늘 모든 약을 복용하셨습니다! 🎉'
                    : totalRequiredDoses > 0
                    ? '위의 체크박스를 눌러 복용을 완료해주세요.'
                    : '오늘 복용할 약이 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isAllCompleted
                          ? Colors.green.shade600
                          : Colors.blue.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyAchievementGrid() {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        // 현재 월의 날짜 정보 계산
        final now = DateTime.now();
        final currentYear = now.year;
        final currentMonth = now.month;
        final currentDay = now.day;

        // 현재 월의 첫 번째 날짜와 마지막 날짜
        final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
        final lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);

        // 첫 번째 날짜의 요일 (0: 일요일, 1: 월요일, ..., 6: 토요일)
        final firstDayWeekday = firstDayOfMonth.weekday % 7; // 일요일을 0으로 변환
        final daysInMonth = lastDayOfMonth.day;

        // 실제 복용 달성률 데이터 가져오기
        final monthlyRates = reminderProvider.getMonthlyCompletionRates(
          currentYear,
          currentMonth,
        );

        // 전체 주 수 계산 (첫 주의 빈 칸 + 날짜 수)
        final totalWeeks = ((firstDayWeekday + daysInMonth) / 7).ceil();

        return Column(
          children: [
            // 월 표시
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                '${currentYear}년 ${currentMonth}월',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF174D4D),
                ),
              ),
            ),
            // 요일 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  ['일', '월', '화', '수', '목', '금', '토'].map((day) {
                    return SizedBox(
                      width: 35.0,
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF174D4D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 8),
            // 날짜 그리드
            ...List.generate(totalWeeks, (weekIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (dayIndex) {
                    final gridIndex = weekIndex * 7 + dayIndex;

                    // 첫 주의 빈 칸들
                    if (gridIndex < firstDayWeekday) {
                      return const SizedBox(width: 35.0, height: 35.0);
                    }

                    // 월의 날짜 범위를 벗어나는 경우
                    final dayNumber = gridIndex - firstDayWeekday + 1;
                    if (dayNumber > daysInMonth) {
                      return const SizedBox(width: 35.0, height: 35.0);
                    }

                    // 실제 달성률 데이터 사용
                    final completionRate = monthlyRates[dayNumber] ?? 0.0;
                    final isToday = dayNumber == currentDay;
                    final isFutureDate = completionRate == -1;

                    return _buildDailyAchievementItem(
                      dayNumber,
                      completionRate,
                      isToday,
                      isFutureDate,
                    );
                  }),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildDailyAchievementItem(
    int day,
    double completionRate, [
    bool isToday = false,
    bool isFutureDate = false,
  ]) {
    // 80% 이상이면 완료로 간주, 미래 날짜는 미완료로 처리
    bool isCompleted = !isFutureDate && completionRate >= 80;

    return GestureDetector(
      onTap: () {
        // 스탬프 클릭 시 상세 정보 표시 (선택사항)
      },
      child: Container(
        width: 35.0,
        height: 35.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getDayBackgroundColor(
            isToday,
            isCompleted,
            isFutureDate,
            completionRate,
          ),
          border: Border.all(
            color: _getDayBorderColor(isToday, isCompleted, isFutureDate),
            width: isToday ? 2.0 : 1.5,
          ),
          boxShadow:
              isToday || isCompleted
                  ? [
                    BoxShadow(
                      color:
                          isToday
                              ? Colors.blue.shade200
                              : Colors.green.shade200,
                      blurRadius: isToday ? 6 : 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isFutureDate) ...[
              // 미래 날짜는 날짜만 표시
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
            ] else if (isCompleted) ...[
              // 완료된 날짜는 체크 아이콘
              Icon(Icons.check_circle, size: 16.0, color: Colors.white),
            ] else if (completionRate > 0) ...[
              // 부분 완료된 날짜는 퍼센트 표시
              Text(
                '${completionRate.round()}%',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: isToday ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ] else ...[
              // 미완료 날짜는 날짜만 표시
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isToday ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 날짜별 배경색을 결정하는 헬퍼 메서드
  Color _getDayBackgroundColor(
    bool isToday,
    bool isCompleted,
    bool isFutureDate,
    double completionRate,
  ) {
    if (isToday) {
      return Colors.blue.shade300;
    } else if (isFutureDate) {
      return Colors.grey.shade100;
    } else if (isCompleted) {
      return Colors.green.shade400;
    } else if (completionRate > 50) {
      return Colors.orange.shade300;
    } else if (completionRate > 0) {
      return Colors.red.shade300;
    } else {
      return Colors.grey.shade200;
    }
  }

  // 날짜별 테두리색을 결정하는 헬퍼 메서드
  Color _getDayBorderColor(bool isToday, bool isCompleted, bool isFutureDate) {
    if (isToday) {
      return Colors.blue.shade600;
    } else if (isFutureDate) {
      return Colors.grey.shade300;
    } else if (isCompleted) {
      return Colors.green.shade600;
    } else {
      return Colors.grey.shade400;
    }
  }
}
