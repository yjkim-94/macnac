import 'package:flutter/material.dart';
import '../models/news_article_model.dart';

/// Bento Grid 레이아웃 위젯
/// 가변 크기 타일을 지원하는 그리드 시스템
class BentoGrid extends StatelessWidget {
  final List<NewsArticleModel> articles;
  final Function(NewsArticleModel) onTileTap;
  final int crossAxisCount;
  final double spacing;

  const BentoGrid({
    super.key,
    required this.articles,
    required this.onTileTap,
    this.crossAxisCount = 2,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1, // 기본 정사각형
      ),
      itemCount: _calculateGridItemCount(),
      itemBuilder: (context, index) {
        final position = _getArticleAtGridPosition(index);
        if (position == null) {
          return const SizedBox.shrink(); // 빈 공간
        }

        final article = articles[position.articleIndex];
        return _buildGridTile(context, article);
      },
    );
  }

  /// 그리드 총 아이템 수 계산 (타일 크기 고려)
  int _calculateGridItemCount() {
    int totalCells = 0;
    for (var article in articles) {
      totalCells += article.tileSize.width * article.tileSize.height;
    }
    // 그리드 행 수 계산
    return ((totalCells / crossAxisCount).ceil() * crossAxisCount);
  }

  /// 특정 그리드 위치의 아티클 찾기
  _ArticlePosition? _getArticleAtGridPosition(int gridIndex) {
    int currentCell = 0;

    for (int i = 0; i < articles.length; i++) {
      final article = articles[i];
      final cellCount = article.tileSize.width * article.tileSize.height;

      // 현재 아티클이 차지하는 셀 범위
      if (gridIndex >= currentCell && gridIndex < currentCell + cellCount) {
        // 첫 번째 셀만 렌더링 (나머지는 빈 공간)
        if (gridIndex == currentCell) {
          return _ArticlePosition(articleIndex: i, isMainCell: true);
        }
        return null; // 타일의 추가 공간
      }
      currentCell += cellCount;
    }

    return null;
  }

  /// 타일 빌드
  Widget _buildGridTile(BuildContext context, NewsArticleModel article) {
    return GestureDetector(
      onTap: () => onTileTap(article),
      child: _BentoTile(
        article: article,
        size: article.tileSize,
      ),
    );
  }
}

/// 그리드 위치 정보
class _ArticlePosition {
  final int articleIndex;
  final bool isMainCell;

  _ArticlePosition({
    required this.articleIndex,
    required this.isMainCell,
  });
}

/// Bento 타일 위젯
class _BentoTile extends StatefulWidget {
  final NewsArticleModel article;
  final GridTileSize size;

  const _BentoTile({
    required this.article,
    required this.size,
  });

  @override
  State<_BentoTile> createState() => _BentoTileState();
}

class _BentoTileState extends State<_BentoTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Hero(
          tag: 'news-${widget.article.id}',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isPressed ? 0.1 : 0.05),
                  blurRadius: _isPressed ? 15 : 10,
                  offset: Offset(0, _isPressed ? 4 : 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 배경 이미지
                  if (widget.article.imageUrl != null)
                    Positioned.fill(
                      child: Image.network(
                        widget.article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                        ),
                      ),
                    ),

                  // 그라데이션 오버레이
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 콘텐츠
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 태그 (large 타일에만 표시)
                        if (widget.size == GridTileSize.large &&
                            widget.article.tags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Wrap(
                              spacing: 4,
                              children: widget.article.tags.take(2).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        // 제목
                        Text(
                          widget.article.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getTitleFontSize(widget.size),
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: _getTitleMaxLines(widget.size),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // 출처 및 시간
                        Row(
                          children: [
                            Text(
                              widget.article.publisher,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTimeAgo(widget.article.publishedAt),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 타일 크기에 따른 제목 폰트 크기
  double _getTitleFontSize(GridTileSize size) {
    switch (size) {
      case GridTileSize.small:
        return 14;
      case GridTileSize.wide:
      case GridTileSize.tall:
        return 16;
      case GridTileSize.large:
        return 18;
    }
  }

  /// 타일 크기에 따른 제목 최대 라인 수
  int _getTitleMaxLines(GridTileSize size) {
    switch (size) {
      case GridTileSize.small:
        return 2;
      case GridTileSize.wide:
        return 2;
      case GridTileSize.tall:
        return 3;
      case GridTileSize.large:
        return 4;
    }
  }

  /// 시간 포맷 (n시간 전)
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
