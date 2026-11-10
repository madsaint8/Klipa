class Beneficiary {
  final String id;
  final String userId;
  final String contactUserId;
  final String? nickname;
  final bool isFavorite;
  final DateTime createdAt;

  // Joined from users table
  final String? fullName;
  final String? phone;
  final String? profilePic;

  const Beneficiary({
    required this.id,
    required this.userId,
    required this.contactUserId,
    this.nickname,
    required this.isFavorite,
    required this.createdAt,
    this.fullName,
    this.phone,
    this.profilePic,
  });

  String get displayName => nickname ?? fullName ?? 'Unknown';

  String get initials {
    final name = displayName;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    final user = json['beneficiary_user'] as Map<String, dynamic>?;
    return Beneficiary(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      contactUserId: json['contact_user_id'] as String,
      nickname: json['nickname'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      fullName: user?['full_name'] as String?,
      phone: user?['phone'] as String?,
      profilePic: user?['profile_pic'] as String?,
    );
  }

  Beneficiary copyWith({bool? isFavorite, String? nickname}) {
    return Beneficiary(
      id: id,
      userId: userId,
      contactUserId: contactUserId,
      nickname: nickname ?? this.nickname,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      fullName: fullName,
      phone: phone,
      profilePic: profilePic,
    );
  }
}