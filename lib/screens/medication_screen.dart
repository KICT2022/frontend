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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              reminder['text'],
              style: TextStyle(fontSize: 14, height: 1.3),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () => _showAddReminderDialog(reminder),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _deleteReminder(reminder['id']),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
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
    String medicationNote = ''; // 약 복용 특이사항

    // 수정 모드일 때 기존 데이터 설정
    if (isEditing) {
      final textParts = existingReminder!['text'].split(' • ');
      // "C약 • 매일 • 14:00 • 식후 30분" 형태에서 파싱
      if (textParts.isNotEmpty && textParts[0].contains('약')) {
        medicationName = textParts[0];
      }
      // 기존 시간들을 파싱하여 selectedTimes에 추가
      selectedTimes = _parseTimesFromText(existingReminder['text']);
      selectedDays = List<String>.from(existingReminder['days']);
      // 특이사항 파싱 (마지막 부분이 특이사항일 가능성이 높음)
      if (textParts.length > 3) {
        medicationNote = textParts[3];
      }
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

                    // 약 복용 특이사항 선택
                    Text(
                      '복용 시점',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildNoteChip('식전 30분', medicationNote, (selected) {
                          setState(() {
                            if (selected) {
                              medicationNote = '식전 30분';
                            } else {
                              medicationNote = '';
                            }
                          });
                        }),
                        _buildNoteChip('식후 30분', medicationNote, (selected) {
                          setState(() {
                            if (selected) {
                              medicationNote = '식후 30분';
                            } else {
                              medicationNote = '';
                            }
                          });
                        }),
                        _buildNoteChip('기상 후 30분', medicationNote, (selected) {
                          setState(() {
                            if (selected) {
                              medicationNote = '기상 후 30분';
                            } else {
                              medicationNote = '';
                            }
                          });
                        }),
                        _buildNoteChip('취침 전', medicationNote, (selected) {
                          setState(() {
                            if (selected) {
                              medicationNote = '취침 전';
                            } else {
                              medicationNote = '';
                            }
                          });
                        }),
                        _buildNoteChip('공복 시', medicationNote, (selected) {
                          setState(() {
                            if (selected) {
                              medicationNote = '공복 시';
                            } else {
                              medicationNote = '';
                            }
                          });
                        }),
                        _buildNoteChip('즉시 복용', medicationNote, (selected) {
                          setState(() {
                            if (selected) {
                              medicationNote = '즉시 복용';
                            } else {
                              medicationNote = '';
                            }
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 직접 입력 필드
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                              text:
                                  medicationNote.isNotEmpty &&
                                          ![
                                            '식전 30분',
                                            '식후 30분',
                                            '기상 후 30분',
                                            '취침 전',
                                            '공복 시',
                                            '즉시 복용',
                                          ].contains(medicationNote)
                                      ? medicationNote
                                      : '',
                            ),
                            decoration: InputDecoration(
                              labelText: '직접 입력',
                              hintText: '예: 식후 1시간, 기상 직후',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              medicationNote = value;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              medicationNote = '';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('초기화'),
                        ),
                      ],
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${time.hour.toString().padLeft(2, '0')}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.keyboard_arrow_up,
                                                  size: 16,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    int newHour = time.hour + 1;
                                                    if (newHour > 23)
                                                      newHour = 0;
                                                    selectedTimes[index] =
                                                        TimeOfDay(
                                                          hour: newHour,
                                                          minute: time.minute,
                                                        );
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(
                                                  minWidth: 24,
                                                  minHeight: 24,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 16,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    int newHour = time.hour - 1;
                                                    if (newHour < 0)
                                                      newHour = 23;
                                                    selectedTimes[index] =
                                                        TimeOfDay(
                                                          hour: newHour,
                                                          minute: time.minute,
                                                        );
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(
                                                  minWidth: 24,
                                                  minHeight: 24,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${time.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.keyboard_arrow_up,
                                                  size: 16,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    int newMinute =
                                                        time.minute + 5;
                                                    if (newMinute >= 60)
                                                      newMinute = 0;
                                                    selectedTimes[index] =
                                                        TimeOfDay(
                                                          hour: time.hour,
                                                          minute: newMinute,
                                                        );
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(
                                                  minWidth: 24,
                                                  minHeight: 24,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 16,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    int newMinute =
                                                        time.minute - 5;
                                                    if (newMinute < 0)
                                                      newMinute = 55;
                                                    selectedTimes[index] =
                                                        TimeOfDay(
                                                          hour: time.hour,
                                                          minute: newMinute,
                                                        );
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(
                                                  minWidth: 24,
                                                  minHeight: 24,
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
                    if (medicationName.isNotEmpty &&
                        selectedDays.isNotEmpty &&
                        selectedTimes.isNotEmpty) {
                      if (isEditing) {
                        _updateReminder(
                          existingReminder!['id'],
                          medicationName,
                          selectedTimes,
                          selectedDays,
                          medicationNote,
                        );
                      } else {
                        _addReminder(
                          medicationName,
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

  // 텍스트에서 시간을 파싱하는 메서드 (단일 시간용)
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

  Widget _buildNoteChip(
    String label,
    String selectedNote,
    Function(bool) onSelected,
  ) {
    bool isSelected = selectedNote == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Color(0xFF174D4D).withOpacity(0.3),
      checkmarkColor: Color(0xFF174D4D),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide(
        color: isSelected ? Color(0xFF174D4D) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildMonthlyAchievementGrid() {
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

    // 샘플 데이터 (실제로는 데이터베이스에서 가져와야 함)
    List<int> dailyPercentages = List.generate(daysInMonth, (index) {
      // 랜덤한 달성률 생성 (실제 구현에서는 실제 데이터 사용)
      return 60 + (index * 2) % 40; // 60-99% 범위
    });

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

                final percentage = dailyPercentages[dayNumber - 1];
                final isToday = dayNumber == currentDay;

                return _buildDailyAchievementItem(
                  dayNumber,
                  percentage,
                  isToday,
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDailyAchievementItem(
    int day,
    int percentage, [
    bool isToday = false,
  ]) {
    // 80% 이상이면 완료로 간주
    bool isCompleted = percentage >= 80;

    return GestureDetector(
      onTap: () {
        // 스탬프 클릭 시 상세 정보 표시 (선택사항)
      },
      child: Container(
        width: 35.0,
        height: 35.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              isToday
                  ? Colors.blue.shade300
                  : (isCompleted
                      ? Colors.green.shade400
                      : Colors.grey.shade200),
          border: Border.all(
            color:
                isToday
                    ? Colors.blue.shade600
                    : (isCompleted
                        ? Colors.green.shade600
                        : Colors.grey.shade400),
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
            if (isCompleted) ...[
              Icon(Icons.check_circle, size: 16.0, color: Colors.white),
            ] else ...[
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

  Widget _buildAchievementItem(
    String day,
    int percentage,
    bool isSeniorMode,
    double fontSize,
  ) {
    // 80% 이상이면 완료로 간주
    bool isCompleted = percentage >= 80;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: fontSize - 2,
              fontWeight: FontWeight.w600,
              color: Color(0xFF174D4D),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // 스탬프 클릭 시 상세 정보 표시 (선택사항)
            },
            child: Container(
              width: 45.0,
              height: 45.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isCompleted ? Colors.green.shade400 : Colors.grey.shade200,
                border: Border.all(
                  color:
                      isCompleted
                          ? Colors.green.shade600
                          : Colors.grey.shade400,
                  width: 2,
                ),
                boxShadow:
                    isCompleted
                        ? [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCompleted) ...[
                    Icon(Icons.check_circle, size: 20.0, color: Colors.white),
                    const SizedBox(height: 2),
                    Text(
                      '완료',
                      style: TextStyle(
                        fontSize: fontSize - 4,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.medication,
                      size: 18.0,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: fontSize - 4,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
