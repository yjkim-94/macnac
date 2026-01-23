import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// 법적 문서 화면 (개인정보처리방침, 이용약관)
class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({
    super.key,
    required this.title,
    required this.content,
  });

  /// 개인정보처리방침 화면
  static void showPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LegalScreen(
          title: '개인정보처리방침',
          content: _privacyPolicy,
        ),
      ),
    );
  }

  /// 이용약관 화면
  static void showTermsOfService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LegalScreen(
          title: '이용약관',
          content: _termsOfService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.8,
          ),
        ),
      ),
    );
  }
}

const String _privacyPolicy = '''
개인정보처리방침

최종 수정일: 2024년 1월

MACNAC(이하 "서비스")은 사용자의 개인정보를 중요하게 생각하며, 관련 법령을 준수합니다.

1. 수집하는 개인정보
현재 서비스는 별도의 개인정보를 수집하지 않습니다.
- 회원가입 없이 서비스를 이용할 수 있습니다.
- 기기 식별자 등 자동 수집 정보도 수집하지 않습니다.

2. 개인정보의 이용 목적
수집하는 개인정보가 없으므로 해당 사항이 없습니다.

3. 개인정보의 보관 및 파기
수집하는 개인정보가 없으므로 해당 사항이 없습니다.

4. 제3자 제공
수집하는 개인정보가 없으므로 제3자에게 제공하는 정보가 없습니다.

5. 이용자의 권리
서비스 이용에 관한 문의사항이 있으시면 앱 내 "의견 보내기"를 통해 연락해 주세요.

6. 개인정보처리방침의 변경
본 방침이 변경되는 경우, 앱 내 공지를 통해 안내드립니다.
''';

const String _termsOfService = '''
이용약관

최종 수정일: 2024년 1월

MACNAC 서비스(이하 "서비스")를 이용해 주셔서 감사합니다.

제1조 (목적)
본 약관은 서비스의 이용 조건 및 절차, 기타 필요한 사항을 규정함을 목적으로 합니다.

제2조 (서비스의 내용)
1. 서비스는 매일 주요 뉴스를 요약하여 제공하는 브리핑 서비스입니다.
2. 서비스에서 제공하는 콘텐츠는 원문 뉴스를 재창작한 것으로, 원문과 다를 수 있습니다.
3. 모든 콘텐츠에는 원문 출처가 표기되며, 원문 링크를 통해 원본 기사를 확인할 수 있습니다.

제3조 (저작권)
1. 서비스에서 제공하는 재창작 콘텐츠의 저작권은 서비스 제공자에게 있습니다.
2. 원문 뉴스의 저작권은 해당 언론사에 있습니다.
3. 사용자는 개인적 용도로만 콘텐츠를 이용할 수 있습니다.

제4조 (면책조항)
1. 서비스에서 제공하는 정보는 참고용이며, 투자 등의 결정에 대한 책임은 사용자에게 있습니다.
2. 서비스는 뉴스 요약 서비스로, 정보의 정확성을 보장하지 않습니다.
3. 원문 확인이 필요한 경우 반드시 원문 링크를 통해 확인해 주세요.

제5조 (서비스 변경 및 중단)
1. 서비스는 운영상 필요한 경우 서비스 내용을 변경할 수 있습니다.
2. 천재지변 등 불가항력적 사유가 발생한 경우 서비스가 일시 중단될 수 있습니다.

제6조 (약관의 변경)
1. 본 약관이 변경되는 경우, 앱 내 공지를 통해 안내드립니다.
2. 변경된 약관에 동의하지 않는 경우, 서비스 이용을 중단할 수 있습니다.

문의사항이 있으시면 앱 내 "의견 보내기"를 통해 연락해 주세요.
''';
