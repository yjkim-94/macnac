import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/causality_model.dart';

/// 투자 인사이트 표시 위젯
class InsightWidget extends StatelessWidget {
  final List<InsightModel> insights;

  const InsightWidget({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppColors.accent,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '투자 인사이트',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 인사이트 목록
        ...insights.map((insight) => _InsightCard(insight: insight)),
      ],
    );
  }
}

/// 개별 인사이트 카드
class _InsightCard extends StatelessWidget {
  final InsightModel insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final insightColor = _getInsightColor(insight.type);
    final insightIcon = _getInsightIcon(insight.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insightColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: insightColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (타입 + 중요도)
          Row(
            children: [
              // 타입 아이콘 및 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: insightColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      insightIcon,
                      size: 16,
                      color: insightColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getInsightTypeLabel(insight.type),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: insightColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // 중요도 별표
              ...List.generate(
                5,
                (index) => Icon(
                  index < (insight.importance * 5).round()
                      ? Icons.star
                      : Icons.star_border,
                  size: 16,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 제목
          Text(
            insight.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),

          // 내용
          Text(
            insight.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return AppColors.success;
      case InsightType.negative:
        return AppColors.error;
      case InsightType.neutral:
        return AppColors.textSecondary;
      case InsightType.general:
        return AppColors.info;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Icons.trending_up;
      case InsightType.negative:
        return Icons.trending_down;
      case InsightType.neutral:
        return Icons.trending_flat;
      case InsightType.general:
        return Icons.info_outline;
    }
  }

  String _getInsightTypeLabel(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return '긍정적';
      case InsightType.negative:
        return '부정적';
      case InsightType.neutral:
        return '중립적';
      case InsightType.general:
        return '일반';
    }
  }
}
