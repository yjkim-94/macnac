import 'package:flutter/material.dart';
import '../services/api_exception.dart';

/// 에러 핸들링 유틸리티
class ErrorHandler {
  /// SnackBar로 에러 메시지 표시
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
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

  /// ApiException을 SnackBar로 표시
  static void showApiError(BuildContext context, ApiException error) {
    showError(context, error.userMessage);
  }

  /// 재시도 가능한 에러 다이얼로그
  static Future<bool> showRetryDialog(
    BuildContext context, {
    required String title,
    required String message,
    String retryText = '다시 시도',
    String cancelText = '취소',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(retryText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 성공 메시지 표시
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 경고 메시지 표시
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 정보 메시지 표시
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
