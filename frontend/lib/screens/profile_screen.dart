import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../providers/auth_provider.dart';

/// 프로필 화면
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: ListView(
        children: [
          // 프로필 헤더
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.primary.withOpacity(0.05),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.name?.substring(0, 1) ?? 'U',
                    style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user?.name ?? '사용자', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),

          // 메뉴 목록
          _buildMenuItem(context, Icons.credit_card, '구독 관리', () => Navigator.pushNamed(context, '/subscription')),
          _buildMenuItem(context, Icons.bookmark_outline, '저장한 뉴스', () {}),
          _buildMenuItem(context, Icons.notifications_outlined, '알림 설정', () {}),
          _buildMenuItem(context, Icons.privacy_tip_outlined, '개인정보 처리방침', () {}),
          _buildMenuItem(context, Icons.description_outlined, '서비스 이용약관', () {}),
          _buildMenuItem(context, Icons.info_outline, '앱 정보', () {
            showAboutDialog(context: context, applicationName: 'MACNAC', applicationVersion: '1.0.0');
          }),
          const Divider(),
          _buildMenuItem(context, Icons.logout, '로그아웃', () {
            authProvider.signOut();
            Navigator.of(context).pushReplacementNamed('/login');
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: isDestructive ? AppColors.error : null)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
