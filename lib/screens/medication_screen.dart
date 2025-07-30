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
                        '복약 알림 설정',
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
                          child: const Text('알림 추가하기'),
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
                            '주간 복용 달성률',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF174D4D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 주간 달성률 위젯
                      _buildAchievementItem('월', 85, false, 14),
                      _buildAchievementItem('화', 92, false, 14),
                      _buildAchievementItem('수', 78, false, 14),
                      _buildAchievementItem('목', 95, false, 14),
                      _buildAchievementItem('금', 88, false, 14),
                      _buildAchievementItem('토', 90, false, 14),
                      _buildAchievementItem('일', 82, false, 14),
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

  Widget _buildMedicationSchedule() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 테이블 헤더
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(child: Text('아침', textAlign: TextAlign.center)),
                Expanded(child: Text('점심', textAlign: TextAlign.center)),
                Expanded(child: Text('저녁', textAlign: TextAlign.center)),
              ],
            ),
          ),

          // A약 행
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'A약',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: Text('식전 30분', textAlign: TextAlign.center)),
                Expanded(child: Text('', textAlign: TextAlign.center)),
                Expanded(child: Text('식전 30분', textAlign: TextAlign.center)),
              ],
            ),
          ),

          // B약 행
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'B약',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: Text('식후 30분', textAlign: TextAlign.center)),
                Expanded(child: Text('식후 30분', textAlign: TextAlign.center)),
                Expanded(child: Text('식후 30분', textAlign: TextAlign.center)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(Map<String, dynamic> reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(reminder['text']),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showAddReminderDialog(reminder),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteReminder(reminder['id']),
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
    TimeOfDay selectedTime = TimeOfDay.now();
    List<String> selectedDays = [];

    // 수정 모드일 때 기존 데이터 설정
    if (isEditing) {
      final textParts = existingReminder!['text'].split(' • ');
      // "C약 • 매일 • 14:00" 형태에서 첫 번째 부분이 약 이름
      if (textParts.isNotEmpty && textParts[0].contains('약')) {
        medicationName = textParts[0];
      }
      selectedTime = _parseTimeFromText(existingReminder['text']);
      selectedDays = List<String>.from(existingReminder['days']);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEditing ? '알림 수정하기' : '알림 추가하기',
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
                      controller: TextEditingController(text: medicationName),
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
                    Text(
                      '시간 선택',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // 시간 선택
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${selectedTime.hour.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          int newHour = selectedTime.hour + 1;
                                          if (newHour > 23) newHour = 0;
                                          selectedTime = TimeOfDay(
                                            hour: newHour,
                                            minute: selectedTime.minute,
                                          );
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: 30,
                                        minHeight: 30,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          int newHour = selectedTime.hour - 1;
                                          if (newHour < 0) newHour = 23;
                                          selectedTime = TimeOfDay(
                                            hour: newHour,
                                            minute: selectedTime.minute,
                                          );
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: 30,
                                        minHeight: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // 분 선택
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${selectedTime.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          int newMinute =
                                              selectedTime.minute + 5;
                                          if (newMinute >= 60) newMinute = 0;
                                          selectedTime = TimeOfDay(
                                            hour: selectedTime.hour,
                                            minute: newMinute,
                                          );
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: 30,
                                        minHeight: 30,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          int newMinute =
                                              selectedTime.minute - 5;
                                          if (newMinute < 0) newMinute = 55;
                                          selectedTime = TimeOfDay(
                                            hour: selectedTime.hour,
                                            minute: newMinute,
                                          );
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: 30,
                                        minHeight: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 빠른 시간 선택 버튼들
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickTimeButton(
                          '아침',
                          TimeOfDay(hour: 8, minute: 0),
                          selectedTime,
                          () {
                            setState(() {
                              selectedTime = TimeOfDay(hour: 8, minute: 0);
                            });
                          },
                        ),
                        _buildQuickTimeButton(
                          '점심',
                          TimeOfDay(hour: 12, minute: 0),
                          selectedTime,
                          () {
                            setState(() {
                              selectedTime = TimeOfDay(hour: 12, minute: 0);
                            });
                          },
                        ),
                        _buildQuickTimeButton(
                          '저녁',
                          TimeOfDay(hour: 18, minute: 0),
                          selectedTime,
                          () {
                            setState(() {
                              selectedTime = TimeOfDay(hour: 18, minute: 0);
                            });
                          },
                        ),
                        _buildQuickTimeButton(
                          '취침',
                          TimeOfDay(hour: 22, minute: 0),
                          selectedTime,
                          () {
                            setState(() {
                              selectedTime = TimeOfDay(hour: 22, minute: 0);
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
                    if (medicationName.isNotEmpty && selectedDays.isNotEmpty) {
                      if (isEditing) {
                        _updateReminder(
                          existingReminder!['id'],
                          medicationName,
                          selectedTime,
                          selectedDays,
                        );
                      } else {
                        _addReminder(
                          medicationName,
                          selectedTime,
                          selectedDays,
                        );
                      }
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('약 이름과 요일을 모두 입력해주세요.'),
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
  void _addReminder(String medicationName, TimeOfDay time, List<String> days) {
    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );
    reminderProvider.addReminder(medicationName, timeString, days);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('알림이 추가되었습니다.'), backgroundColor: Colors.green),
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
      SnackBar(content: Text('알림이 삭제되었습니다.'), backgroundColor: Colors.orange),
    );
  }

  // 텍스트에서 시간을 파싱하는 메서드
  TimeOfDay _parseTimeFromText(String text) {
    // "매일 14:00 C약 알림" 형태에서 시간 추출
    final timeRegex = RegExp(r'(\d{1,2}):(\d{2})');
    final match = timeRegex.firstMatch(text);
    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      return TimeOfDay(hour: hour, minute: minute);
    }
    return TimeOfDay.now();
  }

  // 알림을 수정하는 메서드
  void _updateReminder(
    int id,
    String medicationName,
    TimeOfDay time,
    List<String> days,
  ) {
    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );
    reminderProvider.updateReminder(id, medicationName, timeString, days);

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

  Widget _buildAchievementItem(
    String day,
    int percentage,
    bool isSeniorMode,
    double fontSize,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSeniorMode ? 4.0 : 3.0),
      child: Row(
        children: [
          SizedBox(
            width: isSeniorMode ? 32.0 : 28.0,
            child: Text(
              day,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              height: isSeniorMode ? 10.0 : 8.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(isSeniorMode ? 5.0 : 4.0),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(
                      isSeniorMode ? 5.0 : 4.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isSeniorMode ? 10.0 : 8.0),
          SizedBox(
            width: isSeniorMode ? 32.0 : 28.0,
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
