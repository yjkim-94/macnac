/// 사용자 모델
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl;
  final DateTime createdAt;
  final List<String> subscriptions; // 구독 중인 토핑 모듈

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
    required this.createdAt,
    this.subscriptions = const [],
  });

  // JSON to Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      subscriptions: (json['subscriptions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  // Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'subscriptions': subscriptions,
    };
  }

  // copyWith
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    DateTime? createdAt,
    List<String>? subscriptions,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      subscriptions: subscriptions ?? this.subscriptions,
    );
  }
}
