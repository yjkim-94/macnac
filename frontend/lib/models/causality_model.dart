/// 인과관계 분석 모델
class CausalityModel {
  final String cause; // 원인
  final String effect; // 결과
  final double confidence; // 신뢰도 (0.0 ~ 1.0)

  CausalityModel({
    required this.cause,
    required this.effect,
    required this.confidence,
  });

  factory CausalityModel.fromJson(Map<String, dynamic> json) {
    return CausalityModel(
      cause: json['cause'] as String,
      effect: json['effect'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cause': cause,
      'effect': effect,
      'confidence': confidence,
    };
  }
}

/// 투자 인사이트 모델
class InsightModel {
  final String title;
  final String content;
  final InsightType type;
  final double importance; // 중요도 (0.0 ~ 1.0)

  InsightModel({
    required this.title,
    required this.content,
    required this.type,
    required this.importance,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      title: json['title'] as String,
      content: json['content'] as String,
      type: InsightType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InsightType.general,
      ),
      importance: (json['importance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'type': type.name,
      'importance': importance,
    };
  }
}

/// 인사이트 타입
enum InsightType {
  positive, // 긍정적
  negative, // 부정적
  neutral, // 중립적
  general, // 일반
}
