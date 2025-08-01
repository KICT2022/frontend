class ApiConfig {
  // 개발 환경과 운영 환경을 구분
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // 기본 서버 URL
  static const String baseUrl = 'http://15.165.202.101:8080';

  // API 엔드포인트들 (실제 서버 스펙에 맞춤)
  static const String userEndpoint = '/api/v1/users';
  static const String chatEndpoint = '/chat';
  static const String drugInfoEndpoint = '/chat/drug-info';
  static const String drugInteractionEndpoint = '/api/drugs/check';

  // 완전한 API URL들
  static String get loginUrl => '$baseUrl$userEndpoint/login';
  static String get registerUrl => '$baseUrl$userEndpoint/signup';
  static String get sendCodeUrl => '$baseUrl$userEndpoint/send-code';
  static String get verifyCodeUrl => '$baseUrl$userEndpoint/verify-code';
  static String get resetPasswordUrl => '$baseUrl$userEndpoint/reset-password';

  static String get chatUrl => '$baseUrl$chatEndpoint';
  static String get drugInfoUrl => '$baseUrl$drugInfoEndpoint';
  static String get drugInteractionUrl => '$baseUrl$drugInteractionEndpoint';

  // 요청 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 헤더 설정
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
