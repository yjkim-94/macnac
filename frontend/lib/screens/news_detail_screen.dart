import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/news_article_model.dart';
import '../models/news_detail_model.dart';
import '../models/causality_model.dart';
import '../widgets/causality_widget.dart';
import '../widgets/insight_widget.dart';
import '../widgets/source_link_widget.dart';

/// 뉴스 상세 화면
class NewsDetailScreen extends StatelessWidget {
  final NewsArticleModel article;

  const NewsDetailScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    // Mock 데이터 (실제로는 API에서 가져옴)
    final newsDetail = _getMockNewsDetail(article);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 앱바 (이미지 헤더)
          _buildSliverAppBar(context),

          // 콘텐츠
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Hero(
                    tag: 'news-${article.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        article.title,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 태그
                  if (article.tags.isNotEmpty) _buildTags(context),
                  const SizedBox(height: 24),

                  // 재창작된 요약
                  _buildSection(
                    context,
                    icon: Icons.article_outlined,
                    title: '뉴스 요약',
                    child: Text(
                      newsDetail.recreatedContent,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 구분선
                  const Divider(height: 1),
                  const SizedBox(height: 32),

                  // 인과관계 분석
                  CausalityWidget(causalities: newsDetail.causalities),
                  const SizedBox(height: 32),

                  // 구분선
                  const Divider(height: 1),
                  const SizedBox(height: 32),

                  // 투자 인사이트
                  InsightWidget(insights: newsDetail.insights),
                  const SizedBox(height: 32),

                  // 구분선
                  const Divider(height: 1),
                  const SizedBox(height: 32),

                  // 출처 링크
                  SourceLinkWidget(
                    sourceUrl: article.sourceUrl,
                    publisher: article.publisher,
                    publishedAt: article.publishedAt,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 배경 이미지
            if (article.imageUrl != null)
              Image.network(
                article.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primary.withOpacity(0.1),
                ),
              )
            else
              Container(
                color: AppColors.primary.withOpacity(0.1),
              ),

            // 그라데이션 오버레이
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: article.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  // Mock 데이터 생성
  NewsDetailModel _getMockNewsDetail(NewsArticleModel article) {
    return NewsDetailModel(
      article: article,
      recreatedContent:
          '${article.summary}\n\n이번 발표는 시장에 긍정적인 신호로 받아들여지고 있으며, 향후 실적 개선에 대한 기대감을 높이고 있습니다. 전문가들은 이러한 추세가 지속될 경우 주가 상승 모멘텀이 강화될 것으로 전망하고 있습니다.',
      causalities: [
        CausalityModel(
          cause: '${article.publisher}의 3분기 실적 발표',
          effect: '주가 상승 및 시장 기대감 증가',
          confidence: 0.85,
        ),
        CausalityModel(
          cause: '매출 20% 증가 발표',
          effect: '투자자 신뢰도 상승',
          confidence: 0.92,
        ),
      ],
      insights: [
        InsightModel(
          title: '긍정적 실적 전망',
          content: '전년 대비 20% 증가한 매출은 시장 예상을 상회하는 수치입니다. 이는 향후 분기에도 지속적인 성장이 가능함을 시사합니다.',
          type: InsightType.positive,
          importance: 0.9,
        ),
        InsightModel(
          title: '주가 상승 모멘텀',
          content: '실적 개선에 따라 단기적으로 주가 상승이 예상됩니다. 다만, 글로벌 경기 둔화 리스크를 주시할 필요가 있습니다.',
          type: InsightType.general,
          importance: 0.75,
        ),
      ],
      relatedTags: article.tags,
    );
  }
}
