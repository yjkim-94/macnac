/// 데일리 브리핑 모델
class DailyBriefingModel {
  final String id;
  final DateTime date;
  final String? dailySummary; // 오늘의 한 줄 요약
  final List<BriefingNewsItem> newsItems; // 5개 뉴스 요약
  final bool isPremium; // 프리미엄 여부

  DailyBriefingModel({
    required this.id,
    required this.date,
    this.dailySummary,
    required this.newsItems,
    this.isPremium = false,
  });

  /// 오늘 브리핑인지 확인
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// 브리핑 내 개별 뉴스 아이템
class BriefingNewsItem {
  final String id;
  final String title;
  final String summary; // 5-7문장 요약
  final String publisher;
  final String sourceUrl;
  final String? category; // 분야: economy, industry, tech, policy, politics, society, entertainment, sports
  final List<String> tags;

  // 토핑 (유료)
  final CausalityItem? causality; // 인과관계 (토핑)
  final InsightItem? insight; // 투자 인사이트 (토핑)

  BriefingNewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.publisher,
    required this.sourceUrl,
    this.category,
    this.tags = const [],
    this.causality,
    this.insight,
  });

  /// 투자 관련 뉴스인지 (인사이트 제공 가능 여부)
  bool get hasInvestmentRelevance => insight != null;
}

/// 인과관계 아이템
class CausalityItem {
  final String cause;
  final String effect;

  CausalityItem({
    required this.cause,
    required this.effect,
  });
}

/// 투자 인사이트 아이템
class InsightItem {
  final String title;
  final String content;
  final InsightType type;

  InsightItem({
    required this.title,
    required this.content,
    required this.type,
  });
}

enum InsightType { positive, negative, neutral }
