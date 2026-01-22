import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// 인증 상태 관리 Provider
class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

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
        // TODO: 실제로는 토큰 유효성 검증 필요
        _isAuthenticated = true;
        // _user = UserModel.fromJson(jsonDecode(userJson));
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
      notifyListeners();

      // TODO: 실제 API 호출
      await Future.delayed(const Duration(seconds: 1)); // Mock delay

      // Mock user data
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
      // await prefs.setString('user', jsonEncode(_user!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
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
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
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
      notifyListeners();

      // TODO: 실제 API 호출
      await Future.delayed(const Duration(seconds: 1)); // Mock delay

      _user = UserModel(
        id: '1',
        email: email,
        name: name,
        createdAt: DateTime.now(),
        subscriptions: [],
      );

      _isAuthenticated = true;

      // 로컬 저장소에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_token');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Sign up failed: $e');
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      // 로컬 저장소에서 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user');

      _user = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out failed: $e');
    }
  }

  /// 사용자 정보 업데이트
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
