/// API 설정
class ApiConfig {
  // 기본 API URL (개발 환경)
  static const String baseUrl = 'http://localhost:8000';

  // API 버전
  static const String apiVersion = 'v1';

  // API 엔드포인트
  static const String apiPath = '/api/$apiVersion';

  // 전체 API URL
  static String get apiUrl => '$baseUrl$apiPath';

  // 타임아웃 설정 (밀리초)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // 재시도 설정
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 밀리초

  // 헤더
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // 엔드포인트 경로
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authMe = '/auth/me';

  static const String news = '/news';
  static const String newsDetail = '/news'; // /news/{id}
  static const String newsCausality = '/news'; // /news/{id}/causality
  static const String newsInsights = '/news'; // /news/{id}/insights

  static const String subscriptions = '/subscriptions';
  static const String userProfile = '/users/me';
}
