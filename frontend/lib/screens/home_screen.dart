import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../models/news_article_model.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';
import '../widgets/bento_grid.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

/// 홈 화면 - Bento Grid 뉴스 피드
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Mock 모드 여부 (백엔드 연동 전까지 true)
  static const bool _useMockData = true;

  // Mock 데이터
  final List<NewsArticleModel> _mockArticles = [
    NewsArticleModel(
      id: '1',
      title: '테슬라, 3분기 실적 발표... 전년比 20% 증가',
      summary: '테슬라가 3분기 실적을 발표하며 전년 대비 매출 20% 증가를 기록했습니다.',
      imageUrl: 'https://picsum.photos/400/300?random=1',
      publisher: '경제신문',
      sourceUrl: 'https://example.com/news/1',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      tileSize: GridTileSize.large,
      tags: ['테슬라', '실적'],
    ),
    NewsArticleModel(
      id: '2',
      title: '반도체 시장 회복세... 삼성전자 주가 상승',
      summary: '반도체 시장의 회복세에 따라 삼성전자 주가가 급등했습니다.',
      imageUrl: 'https://picsum.photos/400/300?random=2',
      publisher: '기술뉴스',
      sourceUrl: 'https://example.com/news/2',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      tileSize: GridTileSize.small,
      tags: ['반도체'],
    ),
    NewsArticleModel(
      id: '3',
      title: '금리 인하 전망에 부동산 시장 활기',
      summary: '중앙은행의 금리 인하 전망으로 부동산 거래량이 증가하고 있습니다.',
      imageUrl: 'https://picsum.photos/400/300?random=3',
      publisher: '부동산뉴스',
      sourceUrl: 'https://example.com/news/3',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      tileSize: GridTileSize.small,
      tags: ['부동산'],
    ),
    NewsArticleModel(
      id: '4',
      title: 'AI 스타트업 시리즈 B 투자 유치 성공',
      summary: 'AI 기반 서비스를 제공하는 스타트업이 대규모 투자를 유치했습니다.',
      imageUrl: 'https://picsum.photos/400/300?random=4',
      publisher: '스타트업뉴스',
      sourceUrl: 'https://example.com/news/4',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      tileSize: GridTileSize.wide,
      tags: ['AI', '투자'],
    ),
    NewsArticleModel(
      id: '5',
      title: '코스피 2,700선 회복... 외국인 순매수 지속',
      summary: '코스피 지수가 2,700선을 회복하며 상승세를 이어가고 있습니다.',
      imageUrl: 'https://picsum.photos/400/300?random=5',
      publisher: '증권뉴스',
      sourceUrl: 'https://example.com/news/5',
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      tileSize: GridTileSize.small,
      tags: ['코스피'],
    ),
    NewsArticleModel(
      id: '6',
      title: '전기차 배터리 기술 혁신... 주행거리 2배 증가',
      summary: '신규 배터리 기술로 전기차 주행거리가 크게 향상될 전망입니다.',
      imageUrl: 'https://picsum.photos/400/300?random=6',
      publisher: '과학기술',
      sourceUrl: 'https://example.com/news/6',
      publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
      tileSize: GridTileSize.tall,
      tags: ['전기차', '기술'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // API 모드일 때만 데이터 로드
    if (!_useMockData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<NewsProvider>().loadNews();
      });
    }
  }

  void _onArticleTap(NewsArticleModel article) {
    Navigator.of(context).pushNamed('/detail', arguments: article);
  }

  void _onBottomNavTap(int index) {
    if (index == 1) {
      Navigator.of(context).pushNamed('/subscription');
    } else if (index == 2) {
      Navigator.of(context).pushNamed('/profile');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('MACNAC'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알림 기능 (추후 구현)')),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildNewsBody() : _buildPlaceholder(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers_outlined),
            activeIcon: Icon(Icons.layers),
            label: '구독',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showFilterDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.tune),
            )
          : null,
    );
  }

  /// 뉴스 피드 빌드
  Widget _buildNewsBody() {
    if (_useMockData) {
      return _buildMockNewsGrid();
    }
    return _buildApiNewsGrid();
  }

  /// Mock 데이터 그리드
  Widget _buildMockNewsGrid() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: BentoGrid(
        articles: _mockArticles,
        onTileTap: _onArticleTap,
        crossAxisCount: 2,
        spacing: 12,
      ),
    );
  }

  /// API 연동 그리드
  Widget _buildApiNewsGrid() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        // 로딩 상태
        if (newsProvider.listState == LoadingState.loading &&
            newsProvider.articles.isEmpty) {
          return const LoadingWidget(message: '뉴스를 불러오는 중...');
        }

        // 에러 상태
        if (newsProvider.listState == LoadingState.error &&
            newsProvider.articles.isEmpty) {
          return AppErrorWidget(
            message: newsProvider.listError ?? '뉴스를 불러올 수 없습니다.',
            onRetry: () => newsProvider.retryLoadNews(),
          );
        }

        // 빈 상태
        if (newsProvider.articles.isEmpty) {
          return const EmptyWidget(
            title: '뉴스가 없습니다',
            message: '새로운 뉴스를 기다려주세요.',
            icon: Icons.article_outlined,
          );
        }

        // 데이터 표시
        return RefreshIndicator(
          onRefresh: () => newsProvider.loadNews(refresh: true),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // 무한 스크롤
              if (notification is ScrollEndNotification &&
                  notification.metrics.extentAfter < 200) {
                newsProvider.loadMoreNews();
              }
              return false;
            },
            child: Column(
              children: [
                Expanded(
                  child: BentoGrid(
                    articles: newsProvider.articles,
                    onTileTap: _onArticleTap,
                    crossAxisCount: 2,
                    spacing: 12,
                  ),
                ),
                // 추가 로딩 표시
                if (newsProvider.isListLoading && newsProvider.articles.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: LoadingWidget(size: 24),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 플레이스홀더
  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        '화면 준비 중',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  /// 새로고침 처리
  Future<void> _handleRefresh() async {
    if (_useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('새로고침 완료')),
        );
      }
    } else {
      await context.read<NewsProvider>().loadNews(refresh: true);
    }
  }

  /// 검색 다이얼로그
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String query = '';
        return AlertDialog(
          title: const Text('뉴스 검색'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '검색어를 입력하세요',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => query = value,
            onSubmitted: (value) {
              Navigator.pop(context);
              _performSearch(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _performSearch(query);
              },
              child: const Text('검색'),
            ),
          ],
        );
      },
    );
  }

  /// 검색 수행
  void _performSearch(String query) {
    if (query.isEmpty) return;

    if (_useMockData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색: $query (Mock 모드)')),
      );
    } else {
      context.read<NewsProvider>().searchNews(query);
      // TODO: 검색 결과 화면으로 이동
    }
  }

  /// 필터 다이얼로그
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '필터 & 정렬',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('최신순'),
                onTap: () {
                  Navigator.pop(context);
                  if (!_useMockData) {
                    context.read<NewsProvider>().setSortBy('latest');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('인기순'),
                onTap: () {
                  Navigator.pop(context);
                  if (!_useMockData) {
                    context.read<NewsProvider>().setSortBy('popular');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: const Text('관심 태그'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
