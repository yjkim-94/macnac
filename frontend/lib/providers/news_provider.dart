import 'package:flutter/foundation.dart';
import '../models/news_article_model.dart';
import '../models/news_detail_model.dart';
import '../services/news_service.dart';
import '../services/api_exception.dart';

/// 뉴스 데이터 로딩 상태
enum LoadingState {
  initial, // 초기 상태
  loading, // 로딩 중
  loaded, // 로딩 완료
  error, // 에러 발생
}

/// 뉴스 상태 관리 Provider
class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();

  // 뉴스 목록 상태
  List<NewsArticleModel> _articles = [];
  LoadingState _listState = LoadingState.initial;
  String? _listError;
  int _currentPage = 1;
  bool _hasMore = true;
  int _total = 0;

  // 뉴스 상세 상태
  NewsDetailModel? _selectedDetail;
  LoadingState _detailState = LoadingState.initial;
  String? _detailError;

  // 검색 상태
  List<NewsArticleModel> _searchResults = [];
  LoadingState _searchState = LoadingState.initial;
  String? _searchError;
  String _searchQuery = '';

  // 정렬/필터 상태
  String _sortBy = 'latest';
  String? _selectedCategory;
  List<String> _selectedTags = [];

  // Getters
  List<NewsArticleModel> get articles => _articles;
  LoadingState get listState => _listState;
  String? get listError => _listError;
  bool get hasMore => _hasMore;
  int get total => _total;

  NewsDetailModel? get selectedDetail => _selectedDetail;
  LoadingState get detailState => _detailState;
  String? get detailError => _detailError;

  List<NewsArticleModel> get searchResults => _searchResults;
  LoadingState get searchState => _searchState;
  String? get searchError => _searchError;
  String get searchQuery => _searchQuery;

  String get sortBy => _sortBy;
  String? get selectedCategory => _selectedCategory;
  List<String> get selectedTags => _selectedTags;

  bool get isListLoading => _listState == LoadingState.loading;
  bool get isDetailLoading => _detailState == LoadingState.loading;
  bool get isSearchLoading => _searchState == LoadingState.loading;

  /// 뉴스 목록 로드
  Future<void> loadNews({bool refresh = false}) async {
    if (_listState == LoadingState.loading) return;

    if (refresh) {
      _currentPage = 1;
      _articles = [];
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _listState = LoadingState.loading;
    _listError = null;
    notifyListeners();

    try {
      final response = await _newsService.getNewsList(
        page: _currentPage,
        sortBy: _sortBy,
        category: _selectedCategory,
        tags: _selectedTags.isNotEmpty ? _selectedTags : null,
      );

      _articles = refresh ? response.articles : [..._articles, ...response.articles];
      _total = response.total;
      _hasMore = response.hasMore;
      _currentPage++;
      _listState = LoadingState.loaded;
    } on ApiException catch (e) {
      _listError = e.userMessage;
      _listState = LoadingState.error;
      debugPrint('Failed to load news: $e');
    } finally {
      notifyListeners();
    }
  }

  /// 더 많은 뉴스 로드 (페이지네이션)
  Future<void> loadMoreNews() async {
    if (!_hasMore || _listState == LoadingState.loading) return;
    await loadNews();
  }

  /// 뉴스 상세 로드
  Future<void> loadNewsDetail(String newsId) async {
    if (_detailState == LoadingState.loading) return;

    _detailState = LoadingState.loading;
    _detailError = null;
    _selectedDetail = null;
    notifyListeners();

    try {
      final detail = await _newsService.getNewsDetail(newsId);
      _selectedDetail = detail;
      _detailState = LoadingState.loaded;
    } on ApiException catch (e) {
      _detailError = e.userMessage;
      _detailState = LoadingState.error;
      debugPrint('Failed to load news detail: $e');
    } finally {
      notifyListeners();
    }
  }

  /// 뉴스 검색
  Future<void> searchNews(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      _searchState = LoadingState.initial;
      notifyListeners();
      return;
    }

    if (_searchState == LoadingState.loading) return;

    _searchQuery = query;
    _searchState = LoadingState.loading;
    _searchError = null;
    notifyListeners();

    try {
      final response = await _newsService.searchNews(query: query);
      _searchResults = response.articles;
      _searchState = LoadingState.loaded;
    } on ApiException catch (e) {
      _searchError = e.userMessage;
      _searchState = LoadingState.error;
      debugPrint('Failed to search news: $e');
    } finally {
      notifyListeners();
    }
  }

  /// 검색 결과 초기화
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _searchState = LoadingState.initial;
    _searchError = null;
    notifyListeners();
  }

  /// 정렬 방식 변경
  void setSortBy(String sortBy) {
    if (_sortBy == sortBy) return;
    _sortBy = sortBy;
    loadNews(refresh: true);
  }

  /// 카테고리 필터 변경
  void setCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    loadNews(refresh: true);
  }

  /// 태그 필터 변경
  void setTags(List<String> tags) {
    _selectedTags = tags;
    loadNews(refresh: true);
  }

  /// 태그 추가
  void addTag(String tag) {
    if (_selectedTags.contains(tag)) return;
    _selectedTags = [..._selectedTags, tag];
    loadNews(refresh: true);
  }

  /// 태그 제거
  void removeTag(String tag) {
    if (!_selectedTags.contains(tag)) return;
    _selectedTags = _selectedTags.where((t) => t != tag).toList();
    loadNews(refresh: true);
  }

  /// 필터 초기화
  void clearFilters() {
    _sortBy = 'latest';
    _selectedCategory = null;
    _selectedTags = [];
    loadNews(refresh: true);
  }

  /// 상세 화면 데이터 초기화
  void clearDetail() {
    _selectedDetail = null;
    _detailState = LoadingState.initial;
    _detailError = null;
    notifyListeners();
  }

  /// 에러 재시도
  Future<void> retryLoadNews() async {
    await loadNews(refresh: true);
  }

  /// 에러 재시도 (상세)
  Future<void> retryLoadDetail(String newsId) async {
    await loadNewsDetail(newsId);
  }
}
