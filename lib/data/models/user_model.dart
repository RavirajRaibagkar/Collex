class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final double rating;
  final int ratingCount;
  final String? avatarUrl;
  final DateTime? createdAt;
  final String? password;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'student',
    this.rating = 0,
    this.ratingCount = 0,
    this.avatarUrl,
    this.createdAt,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] as int? ?? 0,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'rating': rating,
      'rating_count': ratingCount,
      'avatar_url': avatarUrl,
      'password': password,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    double? rating,
    int? ratingCount,
    String? avatarUrl,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      password: password ?? this.password,
    );
  }
}
