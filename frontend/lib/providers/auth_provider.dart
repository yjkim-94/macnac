import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_exception.dart';

/// 인증 상태 관리 Provider
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _error;

  // Mock 모드 여부 (백엔드 연동 전까지 true)
  static const bool _useMockData = true;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _loadUserFromStorage();
  }

  /// 로컬 저장소에서 사용자 정보 로드
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user');

      if (token != null && userJson != null) {
        if (_useMockData) {
          _user = UserModel.fromJson(jsonDecode(userJson));
          _isAuthenticated = true;
        } else {
          // 토큰 유효성 검증
          try {
            _user = await _authService.getCurrentUser();
            _isAuthenticated = true;
          } on ApiException {
            // 토큰이 유효하지 않으면 로그아웃 처리
            await _clearStorage();
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load user from storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 로그인
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_useMockData) {
        // Mock 데이터
        await Future.delayed(const Duration(seconds: 1));

        _user = UserModel(
          id: '1',
          email: email,
          name: '테스트 사용자',
          createdAt: DateTime.now(),
          subscriptions: [],
        );

        _isAuthenticated = true;

        // 로컬 저장소에 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'mock_token');
        await prefs.setString('user', jsonEncode(_user!.toJson()));
      } else {
        // 실제 API 호출
        final response = await _authService.login(
          email: email,
          password: password,
        );

        _user = response.user;
        _isAuthenticated = true;

        // 토큰 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.accessToken);
        if (response.refreshToken != null) {
          await prefs.setString('refresh_token', response.refreshToken!);
        }
        await prefs.setString('user', jsonEncode(_user!.toJson()));
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign in failed: $e');
      return false;
    } catch (e) {
      _error = '로그인 중 오류가 발생했습니다.';
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign in failed: $e');
      return false;
    }
  }

  /// 소셜 로그인 (Google)
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Google Sign In 구현
      await Future.delayed(const Duration(seconds: 1)); // Mock delay

      _user = UserModel(
        id: '1',
        email: 'user@gmail.com',
        name: 'Google User',
        createdAt: DateTime.now(),
        subscriptions: [],
      );

      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_google_token');
      await prefs.setString('user', jsonEncode(_user!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Google 로그인에 실패했습니다.';
      _isLoading = false;
      notifyListeners();
      debugPrint('Google sign in failed: $e');
      return false;
    }
  }

  /// 회원가입
  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_useMockData) {
        // Mock 데이터
        await Future.delayed(const Duration(seconds: 1));

        _user = UserModel(
          id: '1',
          email: email,
          name: name,
          createdAt: DateTime.now(),
          subscriptions: [],
        );

        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'mock_token');
        await prefs.setString('user', jsonEncode(_user!.toJson()));
      } else {
        // 실제 API 호출
        final response = await _authService.register(
          email: email,
          password: password,
          name: name,
        );

        _user = response.user;
        _isAuthenticated = true;

        // 토큰 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.accessToken);
        if (response.refreshToken != null) {
          await prefs.setString('refresh_token', response.refreshToken!);
        }
        await prefs.setString('user', jsonEncode(_user!.toJson()));
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign up failed: $e');
      return false;
    } catch (e) {
      _error = '회원가입 중 오류가 발생했습니다.';
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign up failed: $e');
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      if (!_useMockData) {
        try {
          await _authService.logout();
        } catch (e) {
          // 서버 로그아웃 실패해도 로컬 토큰은 삭제
          debugPrint('Server logout failed: $e');
        }
      }

      await _clearStorage();

      _user = null;
      _isAuthenticated = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out failed: $e');
    }
  }

  /// 로컬 저장소 클리어
  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
  }

  /// 사용자 정보 업데이트
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
