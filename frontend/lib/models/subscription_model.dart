/// 구독 토핑 모델
class SubscriptionToppingModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int price; // 월 가격 (원)
  final bool isPopular;

  SubscriptionToppingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    this.isPopular = false,
  });
}
