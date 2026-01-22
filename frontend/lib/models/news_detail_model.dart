import 'news_article_model.dart';
import 'causality_model.dart';

/// 뉴스 상세 정보 모델
class NewsDetailModel {
  final NewsArticleModel article;
  final String recreatedContent; // 재창작된 콘텐츠
  final List<CausalityModel> causalities; // 인과관계 분석
  final List<InsightModel> insights; // 투자 인사이트
  final List<String> relatedTags; // 관련 태그

  NewsDetailModel({
    required this.article,
    required this.recreatedContent,
    required this.causalities,
    required this.insights,
    this.relatedTags = const [],
  });

  factory NewsDetailModel.fromJson(Map<String, dynamic> json) {
    return NewsDetailModel(
      article: NewsArticleModel.fromJson(json['article']),
      recreatedContent: json['recreated_content'] as String,
      causalities: (json['causalities'] as List<dynamic>)
          .map((e) => CausalityModel.fromJson(e))
          .toList(),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => InsightModel.fromJson(e))
          .toList(),
      relatedTags: (json['related_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'article': article.toJson(),
      'recreated_content': recreatedContent,
      'causalities': causalities.map((e) => e.toJson()).toList(),
      'insights': insights.map((e) => e.toJson()).toList(),
      'related_tags': relatedTags,
    };
  }
}
