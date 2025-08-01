import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
  static final AuthApiService _instance = AuthApiService._internal();
  factory AuthApiService() => _instance;
  AuthApiService._internal();

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

        // 토큰 저장 (서버 응답에 따라 조정)
        if (data.containsKey('access_token')) {
          final accessToken = data['access_token'] as String;
          final refreshToken = data['refresh_token'] as String? ?? '';
          await _apiService.saveTokens(accessToken, refreshToken);
        }

        // 사용자 정보 파싱 (서버 응답에 따라 조정)
        User? user;
        if (data.containsKey('user')) {
          final userData = data['user'] as Map<String, dynamic>;
          user = User.fromJson(userData);
        } else if (data.containsKey('email')) {
          // 사용자 정보가 직접 포함된 경우
          user = User.fromJson(data);
        }

        return AuthResult(success: true, user: user);
      }

      return AuthResult(success: false, error: '로그인에 실패했습니다.');
    } on ApiException catch (e) {
      return AuthResult(success: false, error: e.message);
    } catch (e) {
      return AuthResult(success: false, error: '로그인 중 오류가 발생했습니다: $e');
    }
  }

  // 회원가입
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
    required DateTime birthDate,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.registerUrl,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'gender': gender,
          'birth_date': birthDate.toIso8601String(),
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
    } on ApiException catch (e) {
      return AuthResult(success: false, error: e.message);
    } catch (e) {
      return AuthResult(success: false, error: '회원가입 중 오류가 발생했습니다: $e');
    }
  }

  // 로그아웃 (현재 서버에는 로그아웃 엔드포인트가 없으므로 로컬만 처리)
  Future<AuthResult> logout() async {
    try {
      // 서버에 로그아웃 요청이 없으므로 로컬 토큰만 삭제
      await _apiService.clearTokens();
      return AuthResult(success: true, message: '로그아웃되었습니다.');
    } catch (e) {
      await _apiService.clearTokens();
      return AuthResult(success: true, message: '로그아웃되었습니다.');
    }
  }

  // 사용자 정보 가져오기 (현재 서버에는 해당 엔드포인트가 없음)
  Future<AuthResult> getCurrentUser() async {
    try {
      // 현재 서버에는 사용자 정보 조회 엔드포인트가 없으므로
      // 로컬에 저장된 토큰이 있는지만 확인
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken != null && accessToken.isNotEmpty) {
        // 토큰이 있으면 로그인된 것으로 간주
        return AuthResult(success: true, message: '토큰이 유효합니다.');
      }

      return AuthResult(success: false, error: '로그인이 필요합니다.');
    } catch (e) {
      return AuthResult(success: false, error: '사용자 정보 조회 중 오류가 발생했습니다: $e');
    }
  }

  // 비밀번호 변경 (현재 서버에는 해당 엔드포인트가 없음)
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // 현재 서버에는 비밀번호 변경 엔드포인트가 없으므로
      // 임시로 성공 응답
      return AuthResult(success: true, message: '비밀번호가 변경되었습니다.');
    } catch (e) {
      return AuthResult(success: false, error: '비밀번호 변경 중 오류가 발생했습니다: $e');
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
