import 'dart:convert';
import '../config/api_config.dart';
import 'api_service.dart';
import '../models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiService _apiService = ApiService();

  // 로그인
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginUrl,
        data: {'email': email, 'password': password},
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // 토큰 저장
        if (data.containsKey('access_token')) {
          final accessToken = data['access_token'] as String;
          final refreshToken = data['refresh_token'] as String? ?? '';
          await _apiService.saveTokens(accessToken, refreshToken);
        }

        // 사용자 정보 파싱
        User? user;
        if (data.containsKey('user')) {
          final userData = data['user'] as Map<String, dynamic>;
          user = User.fromJson(userData);
        } else if (data.containsKey('email')) {
          user = User.fromJson(data);
        }

        return AuthResult(success: true, user: user);
      }

      return AuthResult(success: false, error: '로그인에 실패했습니다.');
    } catch (e) {
      return AuthResult(success: false, error: '로그인 중 오류가 발생했습니다: $e');
    }
  }

  // 회원가입
  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required String gender,
    required String birthDate,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.registerUrl,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
          'gender': gender,
          'birthDate': birthDate,
          'phoneNumber': phoneNumber,
        },
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // 회원가입 후 자동 로그인 처리
        if (data.containsKey('access_token')) {
          final accessToken = data['access_token'] as String;
          final refreshToken = data['refresh_token'] as String;
          await _apiService.saveTokens(accessToken, refreshToken);

          final userData = data['user'] as Map<String, dynamic>;
          final user = User.fromJson(userData);

          return AuthResult(success: true, user: user);
        }

        return AuthResult(success: true, message: '회원가입이 완료되었습니다.');
      }

      return AuthResult(success: false, error: '회원가입에 실패했습니다.');
    } catch (e) {
      return AuthResult(success: false, error: '회원가입 중 오류가 발생했습니다: $e');
    }
  }

  // 인증 코드 전송
  Future<AuthResult> sendVerificationCode(String email) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.baseUrl}/api/v1/users/send-code?email=$email',
      );

      if (response.success) {
        return AuthResult(success: true, message: '인증 코드가 전송되었습니다.');
      }

      return AuthResult(success: false, error: '인증 코드 전송에 실패했습니다.');
    } catch (e) {
      return AuthResult(success: false, error: '인증 코드 전송 중 오류가 발생했습니다: $e');
    }
  }

  // 인증 코드 확인
  Future<AuthResult> verifyCode(String email, String code) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.baseUrl}/api/v1/users/verify-code?email=$email&code=$code',
      );

      if (response.success) {
        return AuthResult(success: true, message: '인증 코드가 확인되었습니다.');
      }

      return AuthResult(success: false, error: '인증 코드 확인에 실패했습니다.');
    } catch (e) {
      return AuthResult(success: false, error: '인증 코드 확인 중 오류가 발생했습니다: $e');
    }
  }

  // 비밀번호 재설정
  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.resetPasswordUrl,
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.success) {
        return AuthResult(success: true, message: '비밀번호가 재설정되었습니다.');
      }

      return AuthResult(success: false, error: '비밀번호 재설정에 실패했습니다.');
    } catch (e) {
      return AuthResult(success: false, error: '비밀번호 재설정 중 오류가 발생했습니다: $e');
    }
  }

  // 로그아웃
  Future<AuthResult> logout() async {
    try {
      await _apiService.clearTokens();
      return AuthResult(success: true, message: '로그아웃되었습니다.');
    } catch (e) {
      await _apiService.clearTokens();
      return AuthResult(success: true, message: '로그아웃되었습니다.');
    }
  }
}

// 인증 결과 클래스
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? message;

  AuthResult({required this.success, this.user, this.error, this.message});
}
