/// 뉴스 기사 모델
class NewsArticleModel {
  final String id;
  final String title;
  final String summary;
  final String? imageUrl;
  final String publisher;
  final String sourceUrl;
  final DateTime publishedAt;
  final GridTileSize tileSize;
  final List<String> tags;

  NewsArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.publisher,
    required this.sourceUrl,
    required this.publishedAt,
    this.tileSize = GridTileSize.small,
    this.tags = const [],
  });

  // JSON to Model
  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      imageUrl: json['image_url'] as String?,
      publisher: json['publisher'] as String,
      sourceUrl: json['source_url'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
      tileSize: GridTileSize.values.firstWhere(
        (e) => e.name == json['tile_size'],
        orElse: () => GridTileSize.small,
      ),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  // Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'image_url': imageUrl,
      'publisher': publisher,
      'source_url': sourceUrl,
      'published_at': publishedAt.toIso8601String(),
      'tile_size': tileSize.name,
      'tags': tags,
    };
  }
}

/// Bento Grid 타일 크기
enum GridTileSize {
  small(width: 1, height: 1), // 1x1
  wide(width: 2, height: 1), // 2x1
  tall(width: 1, height: 2), // 1x2
  large(width: 2, height: 2); // 2x2

  final int width;
  final int height;

  const GridTileSize({required this.width, required this.height});
}
