import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/causality_model.dart';

/// 인과관계 표시 위젯
class CausalityWidget extends StatelessWidget {
  final List<CausalityModel> causalities;

  const CausalityWidget({
    super.key,
    required this.causalities,
  });

  @override
  Widget build(BuildContext context) {
    if (causalities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '인과관계 분석',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 인과관계 목록
        ...causalities.map((causality) => _CausalityItem(
              causality: causality,
            )),
      ],
    );
  }
}

/// 개별 인과관계 아이템
class _CausalityItem extends StatelessWidget {
  final CausalityModel causality;

  const _CausalityItem({required this.causality});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 원인 (Cause)
          _buildBox(
            context,
            label: '원인',
            content: causality.cause,
            color: AppColors.secondary,
          ),

          // 화살표
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Icon(
              Icons.arrow_downward,
              color: AppColors.primary,
              size: 32,
            ),
          ),

          // 결과 (Effect)
          _buildBox(
            context,
            label: '결과',
            content: causality.effect,
            color: AppColors.accent,
          ),

          // 신뢰도
          if (causality.confidence > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Text(
                    '신뢰도:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: causality.confidence,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getConfidenceColor(causality.confidence),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(causality.confidence * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBox(
    BuildContext context, {
    required String label,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 내용
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return AppColors.success;
    } else if (confidence >= 0.5) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
