import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// Dio 기반 API 클라이언트
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // 인터셉터 추가
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_LoggingInterceptor());
  }

  /// 싱글톤 인스턴스
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  /// Dio 인스턴스
  Dio get dio => _dio;

  /// GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DioException을 ApiException으로 변환
  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: '서버 연결 시간이 초과되었습니다.',
          statusCode: 408,
          type: ApiExceptionType.timeout,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);
      case DioExceptionType.cancel:
        return ApiException(
          message: '요청이 취소되었습니다.',
          type: ApiExceptionType.cancelled,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: '네트워크 연결을 확인해주세요.',
          type: ApiExceptionType.network,
        );
      default:
        return ApiException(
          message: e.message ?? '알 수 없는 오류가 발생했습니다.',
          type: ApiExceptionType.unknown,
        );
    }
  }

  /// 응답 에러 처리
  ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;

    String message = '요청 처리 중 오류가 발생했습니다.';
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      message = data['detail'] as String;
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message: message,
          statusCode: statusCode,
          type: ApiExceptionType.badRequest,
        );
      case 401:
        return ApiException(
          message: '인증이 필요합니다.',
          statusCode: statusCode,
          type: ApiExceptionType.unauthorized,
        );
      case 403:
        return ApiException(
          message: '접근 권한이 없습니다.',
          statusCode: statusCode,
          type: ApiExceptionType.forbidden,
        );
      case 404:
        return ApiException(
          message: '요청한 리소스를 찾을 수 없습니다.',
          statusCode: statusCode,
          type: ApiExceptionType.notFound,
        );
      case 500:
      case 502:
      case 503:
        return ApiException(
          message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
          statusCode: statusCode,
          type: ApiExceptionType.serverError,
        );
      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
          type: ApiExceptionType.unknown,
        );
    }
  }
}

/// 인증 인터셉터
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // SharedPreferences에서 토큰 가져오기
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러 시 토큰 갱신 시도
    if (err.response?.statusCode == 401) {
      // TODO: 토큰 갱신 로직 구현
      // final success = await _refreshToken();
      // if (success) {
      //   return handler.resolve(await _retry(err.requestOptions));
      // }
    }
    handler.next(err);
  }
}

/// 로깅 인터셉터 (디버그 모드에서만 동작)
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('>>> [${options.method}] ${options.uri}');
      if (options.data != null) {
        debugPrint('>>> Data: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<<< [${response.statusCode}] ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('!!! [${err.response?.statusCode}] ${err.requestOptions.uri}');
      debugPrint('!!! Error: ${err.message}');
    }
    handler.next(err);
  }
}
