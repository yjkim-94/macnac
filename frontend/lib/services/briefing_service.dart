import 'api_client.dart';
import '../models/briefing_model.dart';

/// 브리핑 API 서비스
class BriefingService {
  final ApiClient _client = ApiClient.instance;

  /// 브리핑 목록 조회 (최근 N일)
  Future<List<DailyBriefingModel>> getBriefings({int days = 7}) async {
    try {
      final response = await _client.get('/briefing', queryParameters: {
        'days': days,
      });

      final List briefings = response.data['briefings'] ?? [];
      return briefings.map((b) => _parseBriefingSummary(b)).toList();
    } catch (e) {
      print('getBriefings error: $e');
      return [];
    }
  }

  /// 오늘의 브리핑 조회
  Future<DailyBriefingModel?> getTodayBriefing() async {
    try {
      final response = await _client.get('/briefing/today');
      return _parseBriefingDetail(response.data);
    } catch (e) {
      print('getTodayBriefing error: $e');
      return null;
    }
  }

  /// 브리핑 상세 조회
  Future<DailyBriefingModel?> getBriefingDetail(String briefingId) async {
    try {
      final response = await _client.get('/briefing/$briefingId');
      return _parseBriefingDetail(response.data);
    } catch (e) {
      print('getBriefingDetail error: $e');
      return null;
    }
  }

  /// 브리핑 생성 요청
  Future<bool> generateBriefing() async {
    try {
      await _client.post('/briefing/generate');
      return true;
    } catch (e) {
      print('generateBriefing error: $e');
      return false;
    }
  }

  DailyBriefingModel _parseBriefingSummary(Map<String, dynamic> data) {
    return DailyBriefingModel(
      id: data['id'] ?? '',
      date: DateTime.parse(data['date']),
      newsItems: [], // 목록에서는 뉴스 아이템 없음
    );
  }

  DailyBriefingModel _parseBriefingDetail(Map<String, dynamic> data) {
    final List items = data['news_items'] ?? [];

    return DailyBriefingModel(
      id: data['id'] ?? '',
      date: DateTime.parse(data['date']),
      dailySummary: data['daily_summary'],  // 오늘의 한 줄 요약
      newsItems: items.map((item) => _parseNewsItem(item)).toList(),
    );
  }

  BriefingNewsItem _parseNewsItem(Map<String, dynamic> data) {
    CausalityItem? causality;
    if (data['causality'] != null) {
      causality = CausalityItem(
        cause: data['causality']['cause'] ?? '',
        effect: data['causality']['effect'] ?? '',
      );
    }

    InsightItem? insight;
    if (data['insight'] != null) {
      insight = InsightItem(
        title: data['insight']['title'] ?? '',
        content: data['insight']['content'] ?? '',
        type: _parseInsightType(data['insight']['type']),
      );
    }

    return BriefingNewsItem(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      publisher: data['publisher'] ?? '',
      sourceUrl: data['source_url'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      causality: causality,
      insight: insight,
    );
  }

  InsightType _parseInsightType(String? type) {
    switch (type) {
      case 'positive':
        return InsightType.positive;
      case 'negative':
        return InsightType.negative;
      default:
        return InsightType.neutral;
    }
  }
}
