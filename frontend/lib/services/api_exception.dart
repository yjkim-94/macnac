/// API 예외 타입
enum ApiExceptionType {
  network, // 네트워크 오류
  timeout, // 타임아웃
  badRequest, // 400
  unauthorized, // 401
  forbidden, // 403
  notFound, // 404
  serverError, // 5xx
  cancelled, // 요청 취소
  unknown, // 알 수 없는 오류
}

/// API 예외 클래스
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiExceptionType type;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.type = ApiExceptionType.unknown,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';

  /// 사용자에게 표시할 메시지
  String get userMessage {
    switch (type) {
      case ApiExceptionType.network:
        return '인터넷 연결을 확인해주세요.';
      case ApiExceptionType.timeout:
        return '서버 응답 시간이 초과되었습니다.';
      case ApiExceptionType.unauthorized:
        return '로그인이 필요합니다.';
      case ApiExceptionType.forbidden:
        return '접근 권한이 없습니다.';
      case ApiExceptionType.notFound:
        return '요청한 정보를 찾을 수 없습니다.';
      case ApiExceptionType.serverError:
        return '서버에 문제가 발생했습니다.';
      case ApiExceptionType.cancelled:
        return '요청이 취소되었습니다.';
      case ApiExceptionType.badRequest:
      case ApiExceptionType.unknown:
      default:
        return message;
    }
  }

  /// 재시도 가능한 에러인지 확인
  bool get isRetryable {
    return type == ApiExceptionType.network ||
        type == ApiExceptionType.timeout ||
        type == ApiExceptionType.serverError;
  }
}
