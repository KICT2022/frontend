import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_api_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  final AuthApiService _authApiService = AuthApiService();
  final ApiService _apiService = ApiService();

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // 앱 시작 시 토큰 초기화 및 자동 로그인 확인
  Future<void> initialize() async {
    await _apiService.initializeTokens();
    await _checkAutoLogin();
  }

  // 자동 로그인 확인
  Future<void> _checkAutoLogin() async {
    try {
      // 토큰이 있는지 먼저 확인
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null || accessToken.isEmpty) {
        return;
      }

      // 토큰이 있으면 사용자 정보 가져오기 시도
      final result = await _authApiService.getCurrentUser();
      if (result.success && result.user != null) {
        _currentUser = result.user;
        notifyListeners();
      }
    } catch (e) {
      // 자동 로그인 실패는 무시 (사용자가 수동 로그인 필요)
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authApiService.login(email, password);

      if (result.success && result.user != null) {
        _currentUser = result.user;

        // 로그인 상태 저장 (SharedPreferences)
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
      } else {
        _error = result.error ?? '로그인에 실패했습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '로그인 중 오류가 발생했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
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
      final result = await _authApiService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        gender: gender,
        birthDate: birthDate,
      );

      if (result.success) {
        // 회원가입 후 자동 로그인된 경우
        if (result.user != null) {
          _currentUser = result.user;

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
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.error ?? '회원가입에 실패했습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '회원가입 중 오류가 발생했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // 서버에 로그아웃 요청
      await _authApiService.logout();
    } catch (e) {
      print('서버 로그아웃 실패: $e');
    }

    // 로컬 데이터 정리
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
    } catch (e) {
      // 로그 기록 (디버깅용)
      print('사용자 정보 로드 중 오류 발생: $e');

      // 에러 상태 설정
      _error = '사용자 정보를 불러오는 중 오류가 발생했습니다.';

      // 상태 업데이트 알림
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 외부에서 사용자 정보 설정
  void setCurrentUser(User user) {
    _currentUser = user;
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
