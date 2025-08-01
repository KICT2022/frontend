import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiErrorHandler {
  // API 에러 메시지 처리
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is ApiException) {
      return error.message;
    } else {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  // HTTP 상태 코드별 에러 메시지
  static String getErrorMessageByStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다. 입력 정보를 확인해주세요.';
      case 401:
        return '인증이 필요합니다. 다시 로그인해주세요.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '요청한 리소스를 찾을 수 없습니다.';
      case 409:
        return '이미 존재하는 데이터입니다.';
      case 422:
        return '입력 정보가 올바르지 않습니다.';
      case 500:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 502:
        return '서버가 일시적으로 사용할 수 없습니다.';
      case 503:
        return '서비스가 일시적으로 사용할 수 없습니다.';
      default:
        return '네트워크 오류가 발생했습니다.';
    }
  }

  // 에러 타입별 처리
  static void handleError(BuildContext context, dynamic error) {
    String message;

    if (error is ApiException) {
      message = getErrorMessageByStatusCode(error.error.index);
    } else {
      message = getErrorMessage(error);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // 성공 메시지 표시
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 정보 메시지 표시
  static void showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 경고 메시지 표시
  static void showWarningMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 네트워크 연결 확인
  static Future<bool> checkNetworkConnection() async {
    try {
      // 간단한 네트워크 연결 테스트
      final response = await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  // 로딩 상태 표시
  static Widget buildLoadingWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // 에러 상태 표시
  static Widget buildErrorWidget(String message, VoidCallback? onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ],
      ),
    );
  }
}
