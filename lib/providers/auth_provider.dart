import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // 등록된 사용자 목록 (실제로는 데이터베이스에서 관리)
  final Map<String, String> _registeredUsers = {
    'test@example.com': 'TestPass123',
    'user@test.com': 'UserPass456',
    'admin@test.com': 'AdminPass789',
  };

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 실제 구현에서는 API 호출
      await Future.delayed(const Duration(milliseconds: 500));

      // 등록된 사용자인지 확인
      if (!_registeredUsers.containsKey(email)) {
        _error = '등록되지 않은 이메일입니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 비밀번호 확인
      if (_registeredUsers[email] != password) {
        _error = '비밀번호가 일치하지 않습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 로그인 성공 - 사용자 정보 생성
      _currentUser = User(
        id: email.hashCode.toString(),
        name: _getUserNameByEmail(email),
        email: email,
        phoneNumber: '010-1234-5678',
        gender: '남',
        birthDate: DateTime(1990, 1, 1),
        medicalHistory: ['위염', '편도염'],
        currentMedications: ['A약', 'B약'],
        guardian: Guardian(
          name: '보호자',
          relationship: '자녀',
          phoneNumber: '010-0000-0000',
        ),
        address: '경기도 용인시 기흥구',
      );

      // 로그인 상태 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _currentUser!.id);
      await prefs.setString('user_email', _currentUser!.email);
      await prefs.setString('user_name', _currentUser!.name);
      await prefs.setString('user_phone', _currentUser!.phoneNumber);
      await prefs.setString('user_gender', _currentUser!.gender);
      await prefs.setString(
        'user_birth_date',
        _currentUser!.birthDate.toIso8601String(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '로그인에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 이메일로 사용자 이름 가져오기
  String _getUserNameByEmail(String email) {
    switch (email) {
      case 'test@example.com':
        return '테스트 사용자';
      case 'user@test.com':
        return '일반 사용자';
      case 'admin@test.com':
        return '관리자';
      default:
        return '사용자';
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
    required DateTime birthDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 실제 구현에서는 API 호출
      await Future.delayed(const Duration(seconds: 1));

      // 이미 등록된 이메일인지 확인
      if (_registeredUsers.containsKey(email)) {
        _error = '이미 등록된 이메일입니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 새 사용자 등록
      _registeredUsers[email] = password;

      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        gender: gender,
        birthDate: birthDate,
        medicalHistory: [],
        currentMedications: [],
        address: '',
      );

      // 회원가입 상태 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _currentUser!.id);
      await prefs.setString('user_email', _currentUser!.email);
      await prefs.setString('user_name', _currentUser!.name);
      await prefs.setString('user_phone', _currentUser!.phoneNumber);
      await prefs.setString('user_gender', _currentUser!.gender);
      await prefs.setString(
        'user_birth_date',
        _currentUser!.birthDate.toIso8601String(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '회원가입에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_gender');
    await prefs.remove('user_birth_date');
    await prefs.remove('user_address');
    await prefs.remove('user_medical_history');
    await prefs.remove('user_current_medications');
    await prefs.remove('guardian_name');
    await prefs.remove('guardian_phone');
    await prefs.remove('guardian_relationship');
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getString('user_id');
      final userEmail = prefs.getString('user_email');
      final userName = prefs.getString('user_name');
      final userPhone = prefs.getString('user_phone');
      final userGender = prefs.getString('user_gender');
      final userBirthDateString = prefs.getString('user_birth_date');
      final userAddress = prefs.getString('user_address');
      final userMedicalHistory =
          prefs.getStringList('user_medical_history') ?? [];
      final userCurrentMedications =
          prefs.getStringList('user_current_medications') ?? [];

      // 보호자 정보 불러오기
      final guardianName = prefs.getString('guardian_name');
      final guardianPhone = prefs.getString('guardian_phone');
      final guardianRelationship = prefs.getString('guardian_relationship');

      Guardian? guardian;
      if (guardianName != null &&
          guardianPhone != null &&
          guardianRelationship != null) {
        guardian = Guardian(
          name: guardianName,
          phoneNumber: guardianPhone,
          relationship: guardianRelationship,
        );
      }

      if (userId != null && userEmail != null && userName != null) {
        DateTime birthDate;
        try {
          birthDate = DateTime.parse(userBirthDateString ?? '');
        } catch (e) {
          birthDate = DateTime(1970, 1, 1);
        }

        _currentUser = User(
          id: userId,
          name: userName,
          email: userEmail,
          phoneNumber: userPhone ?? '',
          gender: userGender ?? '남',
          birthDate: birthDate,
          medicalHistory: userMedicalHistory,
          currentMedications: userCurrentMedications,
          address: userAddress,
          guardian: guardian,
        );

        notifyListeners();
      }
    } catch (e) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> updateUserProfile(User updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 실제 구현에서는 API 호출
      await Future.delayed(const Duration(milliseconds: 500));

      // 사용자 정보 업데이트
      _currentUser = updatedUser;

      // SharedPreferences에 업데이트된 정보 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _currentUser!.id);
      await prefs.setString('user_email', _currentUser!.email);
      await prefs.setString('user_name', _currentUser!.name);
      await prefs.setString('user_phone', _currentUser!.phoneNumber);
      await prefs.setString('user_gender', _currentUser!.gender);
      await prefs.setString(
        'user_birth_date',
        _currentUser!.birthDate.toIso8601String(),
      );

      // 추가 정보들도 저장 (실제 구현에서는 더 체계적으로 관리)
      if (_currentUser!.address != null) {
        await prefs.setString('user_address', _currentUser!.address!);
      }

      // 병력 정보 저장
      await prefs.setStringList(
        'user_medical_history',
        _currentUser!.medicalHistory,
      );

      // 복용중인 약 정보 저장
      await prefs.setStringList(
        'user_current_medications',
        _currentUser!.currentMedications,
      );

      // 보호자 정보 저장
      if (_currentUser!.guardian != null) {
        await prefs.setString('guardian_name', _currentUser!.guardian!.name);
        await prefs.setString(
          'guardian_phone',
          _currentUser!.guardian!.phoneNumber,
        );
        await prefs.setString(
          'guardian_relationship',
          _currentUser!.guardian!.relationship,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '프로필 업데이트에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
