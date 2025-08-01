import '../config/api_config.dart';
import 'api_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiService _apiService = ApiService();

  // 약물 추천 채팅
  Future<ChatResult> sendMessage(String message) async {
    try {
      print('🔍 약 추천 요청: $message');

      final response = await _apiService.post(
        ApiConfig.chatUrl,
        data: {'message': message},
      );

      print('📡 약 추천 응답: success=${response.success}, data=${response.data}');
      print('📄 응답 데이터 타입: ${response.data.runtimeType}');

      if (response.success && response.data != null) {
        // String 형태의 응답 처리
        if (response.data is String) {
          final reply = response.data as String;
          print('✅ String 응답으로 약 추천 성공: $reply');
          return ChatResult(success: true, reply: reply);
        }

        // Map 형태의 응답 처리
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final reply =
              data['reply'] ?? data['message'] ?? data['response'] ?? '';

          print('✅ Map 응답으로 약 추천 성공: $reply');
          return ChatResult(success: true, reply: reply, data: data);
        }

        // 기타 형태의 응답
        print('❓ 알 수 없는 응답 형태: ${response.data.runtimeType}');
        return ChatResult(success: false, error: '알 수 없는 응답 형태입니다.');
      }

      return ChatResult(success: false, error: '메시지 전송에 실패했습니다.');
    } catch (e) {
      print('❌ 약 추천 중 오류: $e');
      return ChatResult(success: false, error: '메시지 전송 중 오류가 발생했습니다: $e');
    }
  }

  // 약물 정보 조회
  Future<DrugInfoResult> getDrugInfo(String drugName) async {
    try {
      print('🔍 약물 정보 조회 요청: $drugName');

      final response = await _apiService.post(
        ApiConfig.drugInfoUrl,
        data: {'message': drugName},
      );

      print(
        '📡 약물 정보 조회 응답: success=${response.success}, data=${response.data}',
      );
      print('📄 응답 데이터 타입: ${response.data.runtimeType}');

      if (response.success && response.data != null) {
        // String 형태의 응답 처리
        if (response.data is String) {
          final drugInfo = response.data as String;
          print('✅ String 응답으로 약물 정보 조회 성공: $drugInfo');
          return DrugInfoResult(success: true, drugInfo: drugInfo);
        }

        // Map 형태의 응답 처리
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final drugInfo =
              data['drugInfo'] ?? data['info'] ?? data['response'] ?? '';

          print('✅ Map 응답으로 약물 정보 조회 성공: $drugInfo');
          return DrugInfoResult(success: true, drugInfo: drugInfo, data: data);
        }

        // 기타 형태의 응답
        print('❓ 알 수 없는 응답 형태: ${response.data.runtimeType}');
        return DrugInfoResult(success: false, error: '알 수 없는 응답 형태입니다.');
      }

      return DrugInfoResult(success: false, error: '약물 정보 조회에 실패했습니다.');
    } catch (e) {
      print('❌ 약물 정보 조회 중 오류: $e');
      return DrugInfoResult(success: false, error: '약물 정보 조회 중 오류가 발생했습니다: $e');
    }
  }

  // 대화 히스토리 조회 (서버에서 지원하는 경우)
  Future<ChatHistoryResult> getChatHistory() async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.baseUrl}/chat/history',
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final history = data['history'] ?? data['messages'] ?? [];

        return ChatHistoryResult(
          success: true,
          history: List<ChatMessage>.from(
            history.map((item) => ChatMessage.fromJson(item)),
          ),
        );
      }

      return ChatHistoryResult(success: false, error: '대화 히스토리 조회에 실패했습니다.');
    } catch (e) {
      return ChatHistoryResult(
        success: false,
        error: '대화 히스토리 조회 중 오류가 발생했습니다: $e',
      );
    }
  }

  // 대화 초기화 (서버에서 지원하는 경우)
  Future<ChatResult> clearChat() async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.baseUrl}/chat/clear',
      );

      if (response.success) {
        return ChatResult(success: true, message: '대화가 초기화되었습니다.');
      }

      return ChatResult(success: false, error: '대화 초기화에 실패했습니다.');
    } catch (e) {
      return ChatResult(success: false, error: '대화 초기화 중 오류가 발생했습니다: $e');
    }
  }

  // 약물 상호작용 확인
  Future<DrugInteractionResult> checkDrugInteractions(
    List<String> drugNames,
  ) async {
    try {
      print('🔍 약물 상호작용 확인 요청: $drugNames');

      final response = await _apiService.post(
        ApiConfig.drugInteractionUrl,
        data: {'drugs': drugNames},
      );

      print(
        '📡 약물 상호작용 응답: success=${response.success}, data=${response.data}',
      );
      print('📄 응답 데이터 타입: ${response.data.runtimeType}');

      if (response.success && response.data != null) {
        // String 형태의 응답 처리
        if (response.data is String) {
          final result = response.data as String;
          print('✅ String 응답으로 약물 상호작용 확인 성공: $result');
          return DrugInteractionResult(success: true, result: result);
        }

        // Map 형태의 응답 처리
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final result =
              data['result'] ??
              data['reply'] ??
              data['message'] ??
              data['response'] ??
              '';

          print('✅ Map 응답으로 약물 상호작용 확인 성공: $result');
          return DrugInteractionResult(
            success: true,
            result: result,
            data: data,
          );
        }

        // 기타 형태의 응답
        print('❓ 알 수 없는 응답 형태: ${response.data.runtimeType}');
        return DrugInteractionResult(success: false, error: '알 수 없는 응답 형태입니다.');
      }

      return DrugInteractionResult(
        success: false,
        error: '약물 상호작용 확인에 실패했습니다.',
      );
    } catch (e) {
      print('❌ 약물 상호작용 확인 중 오류: $e');
      return DrugInteractionResult(
        success: false,
        error: '약물 상호작용 확인 중 오류가 발생했습니다: $e',
      );
    }
  }
}

// 채팅 결과 클래스
class ChatResult {
  final bool success;
  final String? reply;
  final String? error;
  final String? message;
  final Map<String, dynamic>? data;

  ChatResult({
    required this.success,
    this.reply,
    this.error,
    this.message,
    this.data,
  });
}

// 약물 정보 결과 클래스
class DrugInfoResult {
  final bool success;
  final String? drugInfo;
  final String? error;
  final Map<String, dynamic>? data;

  DrugInfoResult({required this.success, this.drugInfo, this.error, this.data});
}

// 채팅 히스토리 결과 클래스
class ChatHistoryResult {
  final bool success;
  final List<ChatMessage>? history;
  final String? error;

  ChatHistoryResult({required this.success, this.history, this.error});
}

// 채팅 메시지 클래스
class ChatMessage {
  final String id;
  final String message;
  final String reply;
  final DateTime timestamp;
  final bool isUser;

  ChatMessage({
    required this.id,
    required this.message,
    required this.reply,
    required this.timestamp,
    required this.isUser,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      reply: json['reply'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      isUser: json['isUser'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'reply': reply,
      'timestamp': timestamp.toIso8601String(),
      'isUser': isUser,
    };
  }
}

// 약물 상호작용 결과 클래스
class DrugInteractionResult {
  final bool success;
  final String? result;
  final String? error;
  final Map<String, dynamic>? data;

  DrugInteractionResult({
    required this.success,
    this.result,
    this.error,
    this.data,
  });
}
