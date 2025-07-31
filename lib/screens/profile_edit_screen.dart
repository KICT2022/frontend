import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _guardianNameController;
  late TextEditingController _guardianPhoneController;
  late TextEditingController _guardianRelationshipController;
  late TextEditingController _customMedicalHistoryController;
  late TextEditingController _customMedicationController;

  String _selectedGender = '남성';
  DateTime _selectedDate = DateTime.now().subtract(
    const Duration(days: 6570),
  ); // 18세
  List<String> _selectedMedicalHistory = [];
  List<String> _selectedCurrentMedications = [];

  final List<String> _genderOptions = ['남성', '여성'];
  final List<String> _medicalHistoryOptions = [
    '고혈압',
    '당뇨',
    '심장질환',
    '간질환',
    '신장질환',
    '위염',
    '편도염',
    '천식',
    '알레르기',
    '관절염',
    '없음',
  ];
  final List<String> _medicationOptions = [
    '고혈압약',
    '당뇨약',
    '심장약',
    '소화제',
    '진통제',
    '항생제',
    '비타민',
    '없음',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController = TextEditingController(text: user.name);
      _phoneController = TextEditingController(text: user.phoneNumber);
      _addressController = TextEditingController(text: user.address ?? '');
      // 성별 매핑
      _selectedGender = user.gender == '남' ? '남성' : '여성';
      _selectedDate = user.birthDate;
      _selectedMedicalHistory = List.from(user.medicalHistory);
      _selectedCurrentMedications = List.from(user.currentMedications);

      if (user.guardian != null) {
        _guardianNameController = TextEditingController(
          text: user.guardian!.name,
        );
        _guardianPhoneController = TextEditingController(
          text: user.guardian!.phoneNumber,
        );
        _guardianRelationshipController = TextEditingController(
          text: user.guardian!.relationship,
        );
      } else {
        _guardianNameController = TextEditingController();
        _guardianPhoneController = TextEditingController();
        _guardianRelationshipController = TextEditingController();
      }
      _customMedicalHistoryController = TextEditingController();
      _customMedicationController = TextEditingController();
    } else {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _addressController = TextEditingController();
      _guardianNameController = TextEditingController();
      _guardianPhoneController = TextEditingController();
      _guardianRelationshipController = TextEditingController();
      _customMedicalHistoryController = TextEditingController();
      _customMedicationController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianRelationshipController.dispose();
    _customMedicalHistoryController.dispose();
    _customMedicationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.currentUser;

        if (currentUser != null) {
          // 보호자 정보 생성
          Guardian? guardian;
          if (_guardianNameController.text.isNotEmpty &&
              _guardianPhoneController.text.isNotEmpty &&
              _guardianRelationshipController.text.isNotEmpty) {
            guardian = Guardian(
              name: _guardianNameController.text,
              phoneNumber: _guardianPhoneController.text,
              relationship: _guardianRelationshipController.text,
            );
          }

          // 업데이트된 사용자 정보
          final updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            name: _nameController.text,
            phoneNumber: _phoneController.text,
            gender: _selectedGender == '남성' ? '남' : '여',
            birthDate: _selectedDate,
            address:
                _addressController.text.isNotEmpty
                    ? _addressController.text
                    : null,
            medicalHistory: _selectedMedicalHistory,
            currentMedications: _selectedCurrentMedications,
            guardian: guardian,
          );

          // AuthProvider를 통해 사용자 정보 업데이트
          await authProvider.updateUserProfile(updatedUser);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('프로필이 성공적으로 수정되었습니다.'),
                backgroundColor: Color(0xFF174D4D),
              ),
            );
            // 프로필 화면으로 돌아가기 전에 상태를 강제로 업데이트
            context.pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('프로필 수정 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          '프로필 수정',
          style: TextStyle(
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
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              '저장',
              style: TextStyle(
                color: Color(0xFF174D4D),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기본 정보 카드
              _buildInfoCard('기본 정보', [
                _buildTextField(
                  controller: _nameController,
                  label: '이름',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _phoneController,
                  label: '전화번호',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '전화번호를 입력해주세요';
                    }
                    return null;
                  },
                ),
                _buildDropdownField(
                  label: '성별',
                  value: _selectedGender,
                  items: _genderOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
                _buildDateField(),
                _buildTextField(
                  controller: _addressController,
                  label: '주소 (선택사항)',
                  maxLines: 2,
                ),
              ]),
              const SizedBox(height: 20),

              // 병력 정보 카드
              _buildInfoCard('병력 정보', [
                _buildMultiSelectField(
                  label: '병력',
                  selectedItems: _selectedMedicalHistory,
                  options: _medicalHistoryOptions,
                  onChanged: (selectedItems) {
                    setState(() {
                      _selectedMedicalHistory = selectedItems;
                    });
                  },
                ),
                _buildCustomInputField(
                  controller: _customMedicalHistoryController,
                  label: '직접 입력',
                  hintText: '추가 병력을 입력하세요',
                  onAdd: () {
                    if (_customMedicalHistoryController.text
                        .trim()
                        .isNotEmpty) {
                      setState(() {
                        _selectedMedicalHistory.add(
                          _customMedicalHistoryController.text.trim(),
                        );
                        _customMedicalHistoryController.clear();
                      });
                    }
                  },
                ),
                _buildSelectedItemsDisplay('선택된 병력', _selectedMedicalHistory, (
                  item,
                ) {
                  setState(() {
                    _selectedMedicalHistory.remove(item);
                  });
                }),
              ]),
              const SizedBox(height: 20),

              // 복용중인 약 카드
              _buildInfoCard('복용중인 약', [
                _buildMultiSelectField(
                  label: '복용중인 약',
                  selectedItems: _selectedCurrentMedications,
                  options: _medicationOptions,
                  onChanged: (selectedItems) {
                    setState(() {
                      _selectedCurrentMedications = selectedItems;
                    });
                  },
                ),
                _buildCustomInputField(
                  controller: _customMedicationController,
                  label: '직접 입력',
                  hintText: '추가 약을 입력하세요',
                  onAdd: () {
                    if (_customMedicationController.text.trim().isNotEmpty) {
                      setState(() {
                        _selectedCurrentMedications.add(
                          _customMedicationController.text.trim(),
                        );
                        _customMedicationController.clear();
                      });
                    }
                  },
                ),
                _buildSelectedItemsDisplay(
                  '선택된 약',
                  _selectedCurrentMedications,
                  (item) {
                    setState(() {
                      _selectedCurrentMedications.remove(item);
                    });
                  },
                ),
              ]),
              const SizedBox(height: 20),

              // 보호자 정보 카드
              _buildInfoCard('보호자 정보 (선택사항)', [
                _buildTextField(
                  controller: _guardianNameController,
                  label: '보호자 이름',
                ),
                _buildTextField(
                  controller: _guardianPhoneController,
                  label: '보호자 전화번호',
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  controller: _guardianRelationshipController,
                  label: '관계',
                  hintText: '예: 배우자, 자녀, 부모님',
                ),
              ]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF174D4D),
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: '생년월일',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> selectedItems,
    required List<String> options,
    required Function(List<String>) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                options.map((option) {
                  final isSelected = selectedItems.contains(option);
                  return FilterChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newSelectedItems = List<String>.from(selectedItems);
                      if (selected) {
                        if (option == '없음') {
                          newSelectedItems.clear();
                          newSelectedItems.add('없음');
                        } else {
                          newSelectedItems.remove('없음');
                          newSelectedItems.add(option);
                        }
                      } else {
                        newSelectedItems.remove(option);
                        if (newSelectedItems.isEmpty) {
                          newSelectedItems.add('없음');
                        }
                      }
                      onChanged(newSelectedItems);
                    },
                    selectedColor: const Color(0xFF174D4D).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF174D4D),
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? const Color(0xFF174D4D) : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required VoidCallback onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onFieldSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      onAdd();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF174D4D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text('추가'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedItemsDisplay(
    String title,
    List<String> selectedItems,
    Function(String) onRemove,
  ) {
    if (selectedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                selectedItems.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF174D4D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF174D4D).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item,
                          style: const TextStyle(
                            color: Color(0xFF174D4D),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => onRemove(item),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
