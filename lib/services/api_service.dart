import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP 클라이언트
  final http.Client _client = http.Client();

  // 인증 토큰
  String? _accessToken;
  String? _refreshToken;

  // 토큰 초기화
  Future<void> initializeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // 토큰 저장
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // 토큰 삭제
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // 인증 헤더 생성
  Map<String, String> _getAuthHeaders() {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);

    // 추가 헤더 설정
    headers['User-Agent'] = 'Flutter-App/1.0';
    headers['Accept'] = 'application/json, text/plain, */*';
    headers['Accept-Language'] = 'ko-KR,ko;q=0.9,en;q=0.8';
    headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
    headers['Pragma'] = 'no-cache';
    headers['Expires'] = '0';

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  // GET 요청
  Future<ApiResponse> get(String endpoint) async {
    try {
      final response = await _client
          .get(Uri.parse(endpoint), headers: _getAuthHeaders())
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ApiException('네트워크 연결을 확인해주세요: $e', ApiError.networkError);
    } on HttpException catch (e) {
      throw ApiException('서버 오류가 발생했습니다: $e', ApiError.serverError);
    } catch (e) {
      throw ApiException('알 수 없는 오류가 발생했습니다: $e', ApiError.unknown);
    }
  }

  // POST 요청
  Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: _getAuthHeaders(),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw ApiException('네트워크 연결을 확인해주세요: $e', ApiError.networkError);
    } on HttpException catch (e) {
      throw ApiException('서버 오류가 발생했습니다: $e', ApiError.serverError);
    } catch (e) {
      throw ApiException('알 수 없는 오류가 발생했습니다: $e', ApiError.unknown);
    }
  }

  // PUT 요청
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _client
          .put(
            Uri.parse(endpoint),
            headers: _getAuthHeaders(),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('네트워크 연결을 확인해주세요', ApiError.networkError);
    } on HttpException {
      throw ApiException('서버 오류가 발생했습니다', ApiError.serverError);
    } catch (e) {
      throw ApiException('알 수 없는 오류가 발생했습니다: $e', ApiError.unknown);
    }
  }

  // DELETE 요청
  Future<ApiResponse> delete(String endpoint) async {
    try {
      final response = await _client
          .delete(Uri.parse(endpoint), headers: _getAuthHeaders())
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('네트워크 연결을 확인해주세요', ApiError.networkError);
    } on HttpException {
      throw ApiException('서버 오류가 발생했습니다', ApiError.serverError);
    } catch (e) {
      throw ApiException('알 수 없는 오류가 발생했습니다: $e', ApiError.unknown);
    }
  }

  // 응답 처리
  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    // JSON 파싱 시도
    dynamic data;
    try {
      data = jsonDecode(body);
    } catch (e) {
      data = body;
    }

    // HTTP 상태 코드가 성공 범위인 경우
    if (statusCode >= 200 && statusCode < 300) {
      // 응답 데이터에서 실제 성공/실패 여부 확인
      bool isSuccess = true;

      if (data is Map<String, dynamic>) {
        // 서버 응답에서 success 필드 확인
        if (data.containsKey('success')) {
          isSuccess = data['success'] == true;
        }
        // error 필드가 있으면 실패로 간주
        else if (data.containsKey('error')) {
          isSuccess = false;
        }
        // message 필드에서 성공/실패 판단
        else if (data.containsKey('message')) {
          final message = data['message'].toString().toLowerCase();
          if (message.contains('실패') ||
              message.contains('오류') ||
              message.contains('error') ||
              message.contains('틀림') ||
              message.contains('invalid') ||
              message.contains('incorrect') ||
              message.contains('wrong') ||
              message.contains('이미 등록된') ||
              message.contains('중복') ||
              message.contains('duplicate')) {
            isSuccess = false;
          }
        }
      }

      return ApiResponse(
        statusCode: statusCode,
        data: data,
        success: isSuccess,
      );
    } else {
      String errorMessage = '서버 오류가 발생했습니다';

      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? data['error'] ?? errorMessage;
      }

      // 인증 오류 처리
      if (statusCode == 401) {
        return _handleUnauthorized();
      }

      throw ApiException(errorMessage, _getApiErrorFromStatusCode(statusCode));
    }
  }

  // 인증 오류 처리
  ApiResponse _handleUnauthorized() {
    // 토큰 만료 시 자동 로그아웃 처리
    clearTokens();
    throw ApiException('인증이 만료되었습니다. 다시 로그인해주세요.', ApiError.unauthorized);
  }

  // 상태 코드에서 API 에러 타입 변환
  ApiError _getApiErrorFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return ApiError.badRequest;
      case 401:
        return ApiError.unauthorized;
      case 403:
        return ApiError.forbidden;
      case 404:
        return ApiError.notFound;
      case 500:
        return ApiError.serverError;
      default:
        return ApiError.unknown;
    }
  }

  // 토큰 새로고침 (현재 서버에는 토큰 새로고침 엔드포인트가 없음)
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      // 현재 서버에는 토큰 새로고침 엔드포인트가 없으므로
      // 임시로 false 반환
      return false;
    } catch (e) {
      // 토큰 새로고침 실패 시 false 반환
    }

    return false;
  }

  // 리소스 정리
  void dispose() {
    _client.close();
  }
}

// API 응답 클래스
class ApiResponse {
  final int statusCode;
  final dynamic data;
  final bool success;

  ApiResponse({
    required this.statusCode,
    required this.data,
    required this.success,
  });
}

// API 예외 클래스
class ApiException implements Exception {
  final String message;
  final ApiError error;

  ApiException(this.message, this.error);

  @override
  String toString() => 'ApiException: $message';
}

// API 에러 타입
enum ApiError {
  networkError,
  serverError,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  unknown,
}
