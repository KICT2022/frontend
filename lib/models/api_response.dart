// API 응답을 위한 공통 모델
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success({T? data, String? message, int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({String? error, String? message, int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final success = json['success'] ?? json['status'] == 'success';
    final data = json['data'];
    final message = json['message'];
    final error = json['error'];
    final statusCode = json['statusCode'];

    return ApiResponse<T>(
      success: success,
      data: data != null && fromJson != null ? fromJson(data) : null,
      message: message,
      error: error,
      statusCode: statusCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'error': error,
      'statusCode': statusCode,
    };
  }
}

// 로그인 요청 모델
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

// 회원가입 요청 모델
class SignupRequest {
  final String name;
  final String email;
  final String password;
  final String passwordConfirm;
  final String gender;
  final String birthDate;
  final String phoneNumber;

  SignupRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirm,
    required this.gender,
    required this.birthDate,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'passwordConfirm': passwordConfirm,
      'gender': gender,
      'birthDate': birthDate,
      'phoneNumber': phoneNumber,
    };
  }
}

// 약물 정보 요청 모델
class DrugInfoRequest {
  final String message;

  DrugInfoRequest({required this.message});

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}

// 채팅 요청 모델
class ChatRequest {
  final String message;

  ChatRequest({required this.message});

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}
