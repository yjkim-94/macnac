import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../models/briefing_model.dart';
import '../services/briefing_service.dart';
import 'legal_screen.dart'; // LegalUrls

/// 홈 화면 - 데일리 브리핑
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // API vs Mock 모드
  static const bool _useMockData = false;  // TODO: 배포 시 false로 변경

  // API 서비스
  final BriefingService _briefingService = BriefingService();

  // 브리핑 데이터
  DailyBriefingModel? _todayBriefing;
  List<DailyBriefingModel> _pastBriefings = [];
  bool _isLoading = true;
  String? _error;

  // 지난 브리핑 보관 기간 (무료: 7일)
  static const int _freeRetentionDays = 7;

  @override
  void initState() {
    super.initState();
    _loadBriefings();
  }

  Future<void> _loadBriefings() async {
    if (_useMockData) {
      _loadMockData();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final today = await _briefingService.getTodayBriefing();

      setState(() {
        _todayBriefing = today;
        _pastBriefings = [];
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // 404 = 브리핑 없음, 그 외 = 연결 실패
        if (e.toString().contains('404')) {
          _todayBriefing = null;
          _error = null; // 브리핑 없음은 에러 아님
        } else {
          _error = '연결에 실패했습니다';
        }
      });
    }
  }

  void _loadMockData() {
    final mockBriefings = _generateMockBriefings();
    setState(() {
      _todayBriefing = mockBriefings.first;
      _pastBriefings = mockBriefings.skip(1).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBriefingBody(),
      // MVP: 하단 네비게이션 제거 - 읽기만 하면 끝
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: const Text(
        'MACNAC',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
          onPressed: () => _showSettingsMenu(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBriefingBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.textPrimary),
      );
    }

    // 연결 실패
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '인터넷 연결을 확인해주세요',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBriefings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.textOnDark,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 브리핑 없음 (준비 중)
    if (_todayBriefing == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text(
              '오늘의 브리핑 준비 중',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '잠시 후 다시 확인해주세요',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBriefings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.textOnDark,
              ),
              child: const Text('새로고침'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.textPrimary,
      onRefresh: _loadBriefings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(),
              const SizedBox(height: 20),
              _buildTodayBriefingCard(_todayBriefing!),
              const SizedBox(height: 32),
              if (_pastBriefings.isNotEmpty) ...[
                _buildSectionHeader('지난 브리핑', '최근 $_freeRetentionDays일'),
                const SizedBox(height: 16),
                _buildPastBriefingList(_pastBriefings),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];

    return Text(
      '${now.month}월 ${now.day}일 ${weekday}요일',
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTodayBriefingCard(DailyBriefingModel briefing) {
    return GestureDetector(
      onTap: () => _openBriefingDetail(briefing),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.article_outlined, color: AppColors.textOnDark, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "TODAY'S BRIEFING",
                      style: TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${briefing.newsItems.length}개 뉴스',
                      style: const TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 오늘의 한 줄 요약
                  if (briefing.dailySummary != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        briefing.dailySummary!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    const Text(
                      '오늘의 뉴스 브리핑',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ...briefing.newsItems.map((item) => _buildNewsPreviewItem(item)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsPreviewItem(BriefingNewsItem item) {
    // 요약에서 첫 문장 추출
    final firstSentence = _getFirstSentence(item.summary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  firstSentence,
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 요약에서 첫 문장 추출
  String _getFirstSentence(String summary) {
    if (summary.isEmpty) return '';
    // 마침표로 첫 문장 분리
    final match = RegExp(r'^[^.]*\.').firstMatch(summary);
    if (match != null) {
      return match.group(0) ?? summary;
    }
    // 마침표가 없으면 전체 반환 (50자 제한)
    return summary.length > 50 ? '${summary.substring(0, 50)}...' : summary;
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
      ],
    );
  }

  Widget _buildPastBriefingList(List<DailyBriefingModel> briefings) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: briefings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildPastBriefingItem(briefings[index]),
    );
  }

  Widget _buildPastBriefingItem(DailyBriefingModel briefing) {
    final dateFormat = DateFormat('M/d');
    return GestureDetector(
      onTap: () => _openBriefingDetail(briefing),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(dateFormat.format(briefing.date), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${briefing.date.month}월 ${briefing.date.day}일 브리핑', style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${briefing.newsItems.length}개 뉴스 요약', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  void _openBriefingDetail(DailyBriefingModel briefing) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BriefingDetailScreen(briefing: briefing)));
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.mail_outline, color: AppColors.textSecondary),
                title: const Text('의견 보내기'),
                onTap: () {
                  Navigator.pop(context);
                  _showFeedbackDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: AppColors.textSecondary),
                title: const Text('이용약관'),
                onTap: () {
                  Navigator.pop(context);
                  LegalUrls.openTermsOfService();
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
                title: const Text('개인정보처리방침'),
                onTap: () {
                  Navigator.pop(context);
                  LegalUrls.openPrivacyPolicy();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('의견 보내기', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '서비스 개선을 위한 의견을 남겨주세요',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final content = controller.text.trim();
              if (content.isEmpty) {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(context);
              final platform = kIsWeb ? 'web' : (Platform.isIOS ? 'ios' : 'android');
              final success = await _briefingService.sendFeedback(content, platform: platform);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? '의견이 전송되었습니다. 감사합니다!' : '전송에 실패했습니다. 다시 시도해주세요.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: AppColors.textOnDark,
            ),
            child: const Text('보내기'),
          ),
        ],
      ),
    );
  }
}

/// 브리핑 상세 화면
class BriefingDetailScreen extends StatelessWidget {
  final DailyBriefingModel briefing;
  const BriefingDetailScreen({super.key, required this.briefing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('${briefing.date.month}월 ${briefing.date.day}일 브리핑', style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 오늘의 한 줄 요약
          if (briefing.dailySummary != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                briefing.dailySummary!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnDark,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          // 뉴스 카드 목록
          ...briefing.newsItems.asMap().entries.map(
            (entry) => _buildNewsCard(context, entry.value, entry.key + 1),
          ),
        ],
      ),
    );
  }

  /// 언론사 이름 정규화
  String _normalizePublisher(String publisher) {
    String name = publisher;

    // 다양한 구분자 처리
    // "::" 기준 분리
    if (name.contains('::')) {
      name = name.split('::').first.trim();
    }
    // ":" 기준 분리 (경향신문:전체기사)
    if (name.contains(':')) {
      name = name.split(':').first.trim();
    }
    // " - " 기준 분리
    if (name.contains(' - ')) {
      final parts = name.split(' - ');
      if (parts.last.trim().length < 10) {
        name = parts.last.trim();
      } else {
        name = parts.first.trim();
      }
    }
    // "|" 기준 분리
    if (name.contains('|')) {
      name = name.split('|').first.trim();
    }

    return name;
  }

  /// 카테고리 한글명
  String _getCategoryName(String? category) {
    const names = {
      'economy': '경제',
      'industry': '산업',
      'tech': '기술',
      'policy': '정책',
      'politics': '정치',
      'society': '사회',
      'entertainment': '연예',
      'sports': '스포츠',
    };
    return names[category] ?? '뉴스';
  }

  Widget _buildNewsCard(BuildContext context, BriefingNewsItem item, int number) {
    final normalizedPublisher = _normalizePublisher(item.publisher);
    final categoryName = _getCategoryName(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 태그 (우상단)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#$categoryName',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 번호 + 타이틀
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text('$number', style: const TextStyle(color: AppColors.textOnDark, fontSize: 12, fontWeight: FontWeight.w600))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 요약
          Text(item.summary, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 16),
          // 출처
          Text(
            '출처 : $normalizedPublisher',
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          // 원문 보기
          GestureDetector(
            onTap: () async {
              final url = Uri.parse(item.sourceUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Row(
              children: const [
                Icon(Icons.open_in_new, size: 14, color: AppColors.textTertiary),
                SizedBox(width: 4),
                Text('원문 보기', style: TextStyle(fontSize: 12, color: AppColors.textTertiary, decoration: TextDecoration.underline)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCausalitySection(CausalityItem causality) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [Icon(Icons.link, size: 14, color: AppColors.textSecondary), SizedBox(width: 6), Text('인과관계', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))]),
          const SizedBox(height: 8),
          Text('${causality.cause} -> ${causality.effect}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildInsightSection(InsightItem insight) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              const Text('투자 인사이트', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const Spacer(),
              _buildInsightBadge(insight.type),
            ],
          ),
          const SizedBox(height: 8),
          Text(insight.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(insight.content, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInsightBadge(InsightType type) {
    final (label, color) = switch (type) {
      InsightType.positive => ('긍정', const Color(0xFF2E7D32)),
      InsightType.negative => ('부정', const Color(0xFFD32F2F)),
      InsightType.neutral => ('중립', AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

/// Mock 데이터 생성
List<DailyBriefingModel> _generateMockBriefings() {
  final now = DateTime.now();
  final summaries = [
    '반도체 호황과 금리 동결 기대감이 증시를 끌어올렸다',
    '테슬라 부진 속 바이오가 새 주도주로 부상',
    '미중 갈등 완화 조짐에 수출주 반등',
    '인플레이션 우려 재부각, 안전자산 선호 심화',
    '2차전지 공급과잉 우려에 관련주 급락',
    'AI 열풍 지속, 빅테크 실적 기대감 확산',
    '한은 금리 동결, 하반기 인하 기대 유지',
  ];
  return List.generate(7, (index) {
    final date = now.subtract(Duration(days: index));
    return DailyBriefingModel(
      id: 'briefing_$index',
      date: date,
      dailySummary: summaries[index],
      newsItems: [
        BriefingNewsItem(id: '${index}_1', title: '코스피 2,700선 돌파, 반도체 대형주 주도', summary: '코스피 지수가 2,700선을 돌파하며 상승 마감했다. 삼성전자와 SK하이닉스 등 반도체 대형주가 상승을 주도했다.', publisher: '한국경제', sourceUrl: 'https://hankyung.com/1', tags: ['코스피'], causality: index == 0 ? CausalityItem(cause: 'AI 반도체 수요 증가', effect: '반도체 주가 상승') : null, insight: index == 0 ? InsightItem(title: '반도체 섹터 비중 확대', content: 'AI 수요 지속 전망', type: InsightType.positive) : null),
        BriefingNewsItem(id: '${index}_2', title: '미 연준 금리 동결, 연내 인하 시사', summary: '미국 연방준비제도가 기준금리를 동결하면서도 연내 금리 인하 가능성을 시사했다.', publisher: '매일경제', sourceUrl: 'https://mk.co.kr/2', tags: ['금리'], causality: index == 0 ? CausalityItem(cause: '금리 인하 기대', effect: '성장주 반등') : null, insight: index == 0 ? InsightItem(title: '성장주 점검', content: '금리 인하시 수혜', type: InsightType.positive) : null),
        BriefingNewsItem(id: '${index}_3', title: '테슬라 1분기 인도량 예상치 하회', summary: '테슬라의 1분기 차량 인도량이 시장 예상치를 하회했다.', publisher: '서울경제', sourceUrl: 'https://sedaily.com/3', tags: ['전기차'], insight: index == 0 ? InsightItem(title: '전기차 신중 접근', content: '경쟁 심화', type: InsightType.negative) : null),
        BriefingNewsItem(id: '${index}_4', title: '삼성바이오 대규모 수주 계약', summary: '삼성바이오로직스가 글로벌 제약사와 대규모 계약을 체결했다.', publisher: '한국경제', sourceUrl: 'https://hankyung.com/4', tags: ['바이오']),
        BriefingNewsItem(id: '${index}_5', title: '원/달러 환율 1,350원대 안착', summary: '원/달러 환율이 안정세를 보이고 있다.', publisher: '매일경제', sourceUrl: 'https://mk.co.kr/5', tags: ['환율']),
      ],
    );
  });
}
