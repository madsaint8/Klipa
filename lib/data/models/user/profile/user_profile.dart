class UserProfile {
  final String id;
  final String fullName;
  final String customerId;
  final String? profilePic;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.customerId,
    this.profilePic,
  });

  /// Name to show in the UI, with a fallback for empty names.
  String get displayName => fullName.trim().isEmpty ? 'Klipa User' : fullName;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: (json['full_name'] as String?) ?? '',
      customerId: (json['customer_id'] as String?) ?? '',
      profilePic: json['profile_pic'] as String?,
    );
  }

  UserProfile copyWith({
    String? fullName,
    String? customerId,
    String? profilePic,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      customerId: customerId ?? this.customerId,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}