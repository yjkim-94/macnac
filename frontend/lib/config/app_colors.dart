import 'package:flutter/material.dart';

/// MACNAC 앱 색상 정의 (모노톤)
class AppColors {
  // Primary Colors (모노톤)
  static const Color primary = Color(0xFF1A1A1A); // 진한 검정
  static const Color primaryLight = Color(0xFF333333);
  static const Color primaryDark = Color(0xFF000000);

  // Secondary Colors
  static const Color secondary = Color(0xFF666666); // 중간 회색
  static const Color secondaryLight = Color(0xFF888888);
  static const Color secondaryDark = Color(0xFF444444);

  // Accent Colors (포인트용)
  static const Color accent = Color(0xFF000000);
  static const Color accentLight = Color(0xFF333333);
  static const Color accentDark = Color(0xFF000000);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA); // 밝은 회색 배경
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A1A);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textOnDark = Color(0xFFFAFAFA);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Status Colors (최소한으로 유지)
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF666666);

  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF333333);
}
