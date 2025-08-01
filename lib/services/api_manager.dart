import 'user_service.dart';
import 'chat_service.dart';
import 'api_service.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;
  ApiManager._internal();

  // 서비스 인스턴스들
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  final ApiService _apiService = ApiService();

  // Getter 메서드들
  UserService get userService => _userService;
  ChatService get chatService => _chatService;
  ApiService get apiService => _apiService;

  // 초기화
  Future<void> initialize() async {
    await _apiService.initializeTokens();
  }

  // 토큰 확인
  Future<bool> hasValidToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      return accessToken != null && accessToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    return await hasValidToken();
  }

  // 로그아웃
  Future<void> logout() async {
    await _userService.logout();
  }

  // 에러 메시지 처리
  String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is ApiException) {
      return error.message;
    } else {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  // 네트워크 연결 상태 확인
  Future<bool> checkNetworkConnection() async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.baseUrl}/v3/api-docs',
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // 서버 상태 확인
  Future<ServerStatus> checkServerStatus() async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.baseUrl}/v3/api-docs',
      );
      if (response.success) {
        return ServerStatus.online;
      } else {
        return ServerStatus.error;
      }
    } catch (e) {
      return ServerStatus.offline;
    }
  }

  // API 서비스 정리
  void dispose() {
    _apiService.dispose();
  }
}

// 서버 상태 열거형
enum ServerStatus { online, offline, error }

// API 매니저 확장 메서드들
extension ApiManagerExtensions on ApiManager {
  // 사용자 인증 관련 편의 메서드들
  Future<AuthResult> login(String email, String password) =>
      userService.login(email, password);

  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required String gender,
    required String birthDate,
    required String phoneNumber,
  }) => userService.signup(
    name: name,
    email: email,
    password: password,
    passwordConfirm: passwordConfirm,
    gender: gender,
    birthDate: birthDate,
    phoneNumber: phoneNumber,
  );

  Future<AuthResult> sendVerificationCode(String email) =>
      userService.sendVerificationCode(email);

  Future<AuthResult> verifyCode(String email, String code) =>
      userService.verifyCode(email, code);

  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) => userService.resetPassword(
    email: email,
    code: code,
    newPassword: newPassword,
    confirmPassword: confirmPassword,
  );

  // 채팅 관련 편의 메서드들
  Future<ChatResult> sendChatMessage(String message) =>
      chatService.sendMessage(message);

  Future<DrugInfoResult> getDrugInfo(String drugName) =>
      chatService.getDrugInfo(drugName);

  Future<ChatHistoryResult> getChatHistory() => chatService.getChatHistory();

  Future<ChatResult> clearChat() => chatService.clearChat();

  Future<DrugInteractionResult> checkDrugInteractions(List<String> drugNames) =>
      chatService.checkDrugInteractions(drugNames);
}
