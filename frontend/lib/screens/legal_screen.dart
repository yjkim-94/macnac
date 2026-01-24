import 'package:url_launcher/url_launcher.dart';

/// 법적 문서 URL (Notion 페이지)
class LegalUrls {
  static const String termsOfService = 'https://parallel-countess-751.notion.site/macnac-2f2ac5a95c0a80ceb088fb8ab7d9eff6?pvs=143';
  static const String privacyPolicy = 'https://parallel-countess-751.notion.site/macnac-2f2ac5a95c0a8036a106dee8f06e1656?pvs=143';

  /// 개인정보처리방침 열기
  static Future<void> openPrivacyPolicy() async {
    final url = Uri.parse(privacyPolicy);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// 이용약관 열기
  static Future<void> openTermsOfService() async {
    final url = Uri.parse(termsOfService);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
