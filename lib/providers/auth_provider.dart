import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

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
      
      // 임시 사용자 데이터
      _currentUser = User(
        id: '1',
        name: '홍길동',
        email: email,
        phoneNumber: '010-1234-5678',
        gender: '남',
        birthDate: DateTime(1970, 1, 1),
        medicalHistory: ['위염', '편도염'],
        currentMedications: ['A약', 'B약'],
        guardian: Guardian(
          name: '홍길동',
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
      await prefs.setString('user_birth_date', _currentUser!.birthDate.toIso8601String());

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
      await prefs.setString('user_birth_date', _currentUser!.birthDate.toIso8601String());

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
          medicalHistory: [],
          currentMedications: [],
          address: '',
        );
        
        notifyListeners();
      }
    } catch (e) {
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 