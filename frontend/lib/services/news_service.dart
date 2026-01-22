import '../config/api_config.dart';
import '../models/news_article_model.dart';
import '../models/news_detail_model.dart';
import '../models/causality_model.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// 뉴스 API 서비스
class NewsService {
  final ApiClient _client = ApiClient.instance;

  /// 뉴스 목록 조회
  Future<NewsListResponse> getNewsList({
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? category,
    List<String>? tags,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.news,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (sortBy != null) 'sort_by': sortBy,
          if (category != null) 'category': category,
          if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
        },
      );

      return NewsListResponse.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }

  /// 뉴스 상세 조회
  Future<NewsDetailModel> getNewsDetail(String newsId) async {
    try {
      final response = await _client.get('${ApiConfig.newsDetail}/$newsId');

      return NewsDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }

  /// 뉴스 인과관계 분석 조회
  Future<List<CausalityModel>> getNewsCausality(String newsId) async {
    try {
      final response =
          await _client.get('${ApiConfig.newsCausality}/$newsId/causality');

      final list = response.data as List<dynamic>;
      return list.map((e) => CausalityModel.fromJson(e)).toList();
    } on ApiException {
      rethrow;
    }
  }

  /// 뉴스 투자 인사이트 조회
  Future<List<InsightModel>> getNewsInsights(String newsId) async {
    try {
      final response =
          await _client.get('${ApiConfig.newsInsights}/$newsId/insights');

      final list = response.data as List<dynamic>;
      return list.map((e) => InsightModel.fromJson(e)).toList();
    } on ApiException {
      rethrow;
    }
  }

  /// 뉴스 검색
  Future<NewsListResponse> searchNews({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        '${ApiConfig.news}/search',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
      );

      return NewsListResponse.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }

  /// 관련 뉴스 조회
  Future<List<NewsArticleModel>> getRelatedNews(
    String newsId, {
    int limit = 5,
  }) async {
    try {
      final response = await _client.get(
        '${ApiConfig.news}/$newsId/related',
        queryParameters: {'limit': limit},
      );

      final list = response.data as List<dynamic>;
      return list.map((e) => NewsArticleModel.fromJson(e)).toList();
    } on ApiException {
      rethrow;
    }
  }
}

/// 뉴스 목록 응답 모델
class NewsListResponse {
  final List<NewsArticleModel> articles;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  NewsListResponse({
    required this.articles,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory NewsListResponse.fromJson(Map<String, dynamic> json) {
    return NewsListResponse(
      articles: (json['articles'] as List<dynamic>)
          .map((e) => NewsArticleModel.fromJson(e))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      hasMore: json['has_more'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articles': articles.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'has_more': hasMore,
    };
  }
}
