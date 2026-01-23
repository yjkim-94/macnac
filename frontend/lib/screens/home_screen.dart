import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../models/briefing_model.dart';
import '../services/briefing_service.dart';

/// 홈 화면 - 데일리 브리핑
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // API vs Mock 모드
  static const bool _useMockData = false;

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
        _pastBriefings = []; // API에서 지난 브리핑도 조회 가능
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '브리핑을 불러올 수 없습니다';
        _isLoading = false;
      });
      // API 실패시 Mock 데이터로 폴백
      _loadMockData();
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
      body: _selectedIndex == 0 ? _buildBriefingBody() : _buildPlaceholder(),
      bottomNavigationBar: _buildBottomNav(),
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
          icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('알림 기능 준비중')),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushNamed('/subscription');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/profile');
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.layers_outlined), activeIcon: Icon(Icons.layers), label: 'Subscription'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBriefingBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.textPrimary),
      );
    }

    if (_todayBriefing == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text(
              '오늘의 브리핑이 없습니다',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
                  const Text(
                    '오늘의 뉴스 브리핑',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...briefing.newsItems.take(3).map((item) => _buildNewsPreviewItem(item)),
                  if (briefing.newsItems.length > 3) ...[
                    const SizedBox(height: 8),
                    Text(
                      '+${briefing.newsItems.length - 3}개 더보기',
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Text('전체 보기', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16, color: AppColors.textPrimary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsPreviewItem(BriefingNewsItem item) {
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
                Text(item.publisher, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildPlaceholder() {
    return Center(child: Text('준비중', style: TextStyle(color: AppColors.textSecondary)));
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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: briefing.newsItems.length,
        itemBuilder: (context, index) => _buildNewsCard(context, briefing.newsItems[index], index + 1),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, BriefingNewsItem item, int number) {
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
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text('$number', style: const TextStyle(color: AppColors.textOnDark, fontSize: 12, fontWeight: FontWeight.w600))),
              ),
              const SizedBox(width: 12),
              Text(item.publisher, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Spacer(),
              if (item.tags.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4)),
                  child: Text('#${item.tags.first}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4)),
          const SizedBox(height: 12),
          Text(item.summary, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          if (item.causality != null) ...[const SizedBox(height: 16), _buildCausalitySection(item.causality!)],
          if (item.insight != null) ...[const SizedBox(height: 16), _buildInsightSection(item.insight!)],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('원문: ${item.sourceUrl}'))),
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
  return List.generate(7, (index) {
    final date = now.subtract(Duration(days: index));
    return DailyBriefingModel(
      id: 'briefing_$index',
      date: date,
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
