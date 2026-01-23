import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/causality_model.dart';

/// 인과관계 표시 위젯 (신뢰도 그래프 제거)
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
          children: const [
            Icon(Icons.link, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 8),
            Text(
              '인과관계 분석',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 인과관계 목록
        ...causalities.map((causality) => _CausalityItem(causality: causality)),
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
      child: Column(
        children: [
          // 원인 (Cause)
          _buildBox(
            label: '원인',
            content: causality.cause,
          ),

          // 화살표
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Icon(
              Icons.arrow_downward,
              color: AppColors.textTertiary,
              size: 24,
            ),
          ),

          // 결과 (Effect)
          _buildBox(
            label: '결과',
            content: causality.effect,
          ),
        ],
      ),
    );
  }

  Widget _buildBox({
    required String label,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 내용
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
