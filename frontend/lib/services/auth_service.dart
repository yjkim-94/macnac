import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// 인증 API 서비스
class AuthService {
  final ApiClient _client = ApiClient.instance;

  /// 로그인
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }

  /// 회원가입
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.authRegister,
        data: {
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        },
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      await _client.post(ApiConfig.authLogout);
    } on ApiException {
      // 로그아웃 실패해도 로컬 토큰은 삭제
      rethrow;
    }
  }

  /// 토큰 갱신
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _client.post(
        ApiConfig.authRefresh,
        data: {
          'refresh_token': refreshToken,
        },
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }

  /// 현재 사용자 정보 조회
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _client.get(ApiConfig.authMe);

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }

  /// 사용자 정보 업데이트
  Future<UserModel> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      final response = await _client.put(
        ApiConfig.userProfile,
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
        },
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }
}

/// 인증 응답 모델
class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int? expiresIn;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }
}
