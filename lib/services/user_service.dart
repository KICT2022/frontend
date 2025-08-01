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
      print('🔍 로그인 요청: email=$email');

      final requestData = {'email': email, 'password': password};
      print('📤 로그인 요청 데이터: $requestData');
      print('📤 로그인 URL: ${ApiConfig.loginUrl}');

      final response = await _apiService.post(
        ApiConfig.loginUrl,
        data: requestData,
      );

      print(
        '📡 로그인 서버 응답: success=${response.success}, statusCode=${response.statusCode}',
      );
      print('📄 로그인 응답 데이터: ${response.data}');
      print('📄 로그인 응답 데이터 타입: ${response.data.runtimeType}');

      if (response.success && response.data != null) {
        // String 형태의 응답 처리 (서버에서 "로그인 성공" 등으로 응답)
        if (response.data is String) {
          final responseString = response.data as String;
          print('✅ String 응답으로 로그인 성공: $responseString');
          return AuthResult(success: true, message: responseString);
        }

        // Map 형태의 응답 처리
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          print('🔍 로그인 응답 데이터 키들: ${data.keys.toList()}');
          data.forEach((key, value) {
            print('  $key: $value (${value.runtimeType})');
          });

          // 토큰 저장 (access_token 또는 token)
          if (data.containsKey('access_token')) {
            final accessToken = data['access_token'] as String;
            final refreshToken = data['refresh_token'] as String? ?? '';
            await _apiService.saveTokens(accessToken, refreshToken);
            print('🔑 access_token 저장 완료');
          } else if (data.containsKey('token')) {
            final token = data['token'] as String;
            await _apiService.saveTokens(token, ''); // refresh token이 없으면 빈 문자열
            print('🔑 token 저장 완료');
          }

          // 사용자 정보 파싱
          User? user;
          if (data.containsKey('user')) {
            final userData = data['user'] as Map<String, dynamic>;
            user = User.fromJson(userData);
            print('👤 사용자 정보 파싱 완료: ${user.name}');
          } else if (data.containsKey('email')) {
            user = User.fromJson(data);
            print('👤 사용자 정보 파싱 완료 (직접): ${user.name}');
          } else {
            // 사용자 정보가 없는 경우 기본 사용자 객체 생성
            user = User(
              id: '0',
              name: '사용자',
              email: email,
              phoneNumber: '',
              gender: '',
              birthDate: DateTime.now(),
              medicalHistory: [],
              currentMedications: [],
              address: '',
            );
            print('👤 기본 사용자 정보 생성');
          }

          return AuthResult(success: true, user: user);
        }

        return AuthResult(success: true, message: '로그인이 완료되었습니다.');
      }

      // 서버에서 받은 에러 메시지 사용
      String errorMessage = '로그인에 실패했습니다.';
      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        errorMessage = data['message'] ?? data['error'] ?? errorMessage;
      }

      return AuthResult(success: false, error: errorMessage);
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
      print('🔍 회원가입 요청: email=$email, name=$name');

      final requestData = {
        'name': name,
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'gender': gender,
        'birthDate': birthDate,
        'phoneNumber': phoneNumber,
        'emailVerified': true, // 이메일 인증 완료 플래그 추가
      };

      print('📤 회원가입 요청 데이터: $requestData');
      print('📤 회원가입 URL: ${ApiConfig.registerUrl}');

      // 이메일 인증이 완료된 상태에서 회원가입 요청
      final registerUrl = '${ApiConfig.registerUrl}?emailVerified=true';
      final response = await _apiService.post(registerUrl, data: requestData);

      print(
        '📡 회원가입 서버 응답: success=${response.success}, statusCode=${response.statusCode}',
      );
      print('📄 회원가입 응답 데이터: ${response.data}');
      print('📄 회원가입 응답 데이터 타입: ${response.data.runtimeType}');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        print('🔍 회원가입 응답 데이터 키들: ${data.keys.toList()}');
        data.forEach((key, value) {
          print('  $key: $value (${value.runtimeType})');
        });
      }

      // HTTP 상태 코드도 확인
      print('📊 HTTP 상태 코드: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ HTTP 오류 상태 코드: ${response.statusCode}');
      }

      if (response.success && response.data != null) {
        // String 형태의 응답 처리 (서버에서 "회원가입 완료" 등으로 응답)
        if (response.data is String) {
          final responseString = response.data as String;
          print('✅ String 응답으로 회원가입 성공: $responseString');
          return AuthResult(success: true, message: responseString);
        }

        // Map 형태의 응답 처리
        if (response.data is Map<String, dynamic>) {
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

        return AuthResult(success: true, message: '회원가입이 완료되었습니다.');
      }

      // 서버에서 받은 에러 메시지 사용
      String errorMessage = '회원가입에 실패했습니다.';
      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        errorMessage = data['message'] ?? data['error'] ?? errorMessage;
      }

      return AuthResult(success: false, error: errorMessage);
    } catch (e) {
      print('❌ 회원가입 중 예외 발생: $e');
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
      // 입력된 코드가 6자리 숫자인지 확인
      if (code.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(code)) {
        return AuthResult(success: false, error: '올바른 6자리 숫자 인증 코드를 입력해주세요.');
      }

      print('🔍 인증 코드 확인 요청: email=$email, code=$code');

      // 매번 새로운 요청을 보내기 위해 타임스탬프 추가
      final response = await _apiService.post(
        '${ApiConfig.baseUrl}/api/v1/users/verify-code?email=$email&code=$code&timestamp=${DateTime.now().millisecondsSinceEpoch}',
      );

      print(
        '📡 서버 응답: success=${response.success}, statusCode=${response.statusCode}',
      );
      print('📄 응답 데이터: ${response.data}');
      print('📄 응답 데이터 타입: ${response.data.runtimeType}');

      // 응답 데이터의 구조를 자세히 분석
      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        print('🔍 응답 데이터 키들: ${data.keys.toList()}');
        data.forEach((key, value) {
          print('  $key: $value (${value.runtimeType})');
        });
      }

      // HTTP 상태 코드 확인
      if (response.statusCode != 200) {
        print('❌ HTTP 오류: ${response.statusCode}');
        return AuthResult(
          success: false,
          error: '서버 오류가 발생했습니다. (${response.statusCode})',
        );
      }

      // 서버 응답 body의 문구로 성공/실패 판단
      bool isSuccess = false;
      String message = '';

      if (response.data != null) {
        // String 형태의 응답 처리
        if (response.data is String) {
          final responseString = response.data as String;
          message = responseString;
          final lowerMessage = responseString.toLowerCase();

          // 성공 문구 확인
          if (lowerMessage.contains('성공') ||
              lowerMessage.contains('완료') ||
              lowerMessage.contains('success') ||
              lowerMessage.contains('인증 완료') ||
              lowerMessage.contains('인증 성공') ||
              lowerMessage.contains('verified') ||
              lowerMessage.contains('valid')) {
            isSuccess = true;
            print('✅ String 응답에서 성공으로 판단: $message');
          }
          // 실패 문구 확인
          else if (lowerMessage.contains('실패') ||
              lowerMessage.contains('오류') ||
              lowerMessage.contains('error') ||
              lowerMessage.contains('틀림') ||
              lowerMessage.contains('인증 실패') ||
              lowerMessage.contains('코드가 일치하지 않습니다') ||
              lowerMessage.contains('invalid') ||
              lowerMessage.contains('incorrect') ||
              lowerMessage.contains('wrong')) {
            isSuccess = false;
            print('❌ String 응답에서 실패로 판단: $message');
          } else {
            // 명확하지 않은 경우 기본적으로 실패로 처리 (보안상 안전)
            isSuccess = false;
            message = '인증 코드가 일치하지 않습니다.';
            print('❓ String 응답이 불명확, 실패로 처리: $message');
          }
        }
        // Map 형태의 응답 처리
        else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;

          // success 필드가 있으면 우선 확인
          if (data.containsKey('success')) {
            isSuccess = data['success'] == true;
            message =
                data['message'] ??
                (isSuccess ? '인증이 완료되었습니다.' : '인증 코드가 일치하지 않습니다.');
            print('✅ success 필드로 판단: $isSuccess, message: $message');
          }
          // message 필드에서 성공/실패 판단
          else if (data.containsKey('message')) {
            message = data['message'] as String;
            final lowerMessage = message.toLowerCase();

            // 성공 문구 확인
            if (lowerMessage.contains('성공') ||
                lowerMessage.contains('완료') ||
                lowerMessage.contains('success') ||
                lowerMessage.contains('인증 완료') ||
                lowerMessage.contains('인증 성공') ||
                lowerMessage.contains('verified') ||
                lowerMessage.contains('valid')) {
              isSuccess = true;
              print('✅ Map 응답에서 성공으로 판단: $message');
            }
            // 실패 문구 확인
            else if (lowerMessage.contains('실패') ||
                lowerMessage.contains('오류') ||
                lowerMessage.contains('error') ||
                lowerMessage.contains('틀림') ||
                lowerMessage.contains('인증 실패') ||
                lowerMessage.contains('코드가 일치하지 않습니다') ||
                lowerMessage.contains('invalid') ||
                lowerMessage.contains('incorrect') ||
                lowerMessage.contains('wrong')) {
              isSuccess = false;
              print('❌ Map 응답에서 실패로 판단: $message');
            } else {
              // 명확하지 않은 경우 기본적으로 실패로 처리 (보안상 안전)
              isSuccess = false;
              message = '인증 코드가 일치하지 않습니다.';
              print('❓ Map 응답이 불명확, 실패로 처리: $message');
            }
          } else {
            // message 필드가 없는 경우
            isSuccess = false;
            message = '인증 코드가 일치하지 않습니다.';
            print('❌ Map에 message 필드 없음, 실패로 처리');
          }
        } else {
          // 기타 형태의 응답
          isSuccess = false;
          message = '인증 코드가 일치하지 않습니다.';
          print('❌ 알 수 없는 응답 형태: ${response.data.runtimeType}');
        }
      } else {
        // 응답 데이터가 없는 경우
        isSuccess = false;
        message = '인증 코드가 일치하지 않습니다.';
        print('❌ 응답 데이터 없음, 실패로 처리');
      }

      if (isSuccess) {
        return AuthResult(success: true, message: '이메일 인증이 완료되었습니다.');
      } else {
        // 실패 시에도 서버에서 받은 메시지를 사용
        return AuthResult(
          success: false,
          error: message.isNotEmpty ? message : '인증 코드가 일치하지 않습니다.',
        );
      }
    } catch (e) {
      print('❌ 인증 코드 확인 중 예외 발생: $e');
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
