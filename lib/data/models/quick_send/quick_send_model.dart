class QuickSendContact {
  final String id;
  final String name;
  final String? phone;
  final String? profilePic;
  final String? recipientId;
  final bool isFavorite;
  final String? nickname;
  final int transferCount;
  final DateTime? lastPaidAt;

  const QuickSendContact({
    required this.id,
    required this.name,
    this.phone,
    this.profilePic,
    this.recipientId,
    this.isFavorite = false,
    this.nickname,
    this.transferCount = 0,
    this.lastPaidAt,
  });

  bool get isAddButton => name == 'Add +';

  /// Display name: nickname takes priority
  String get displayName => nickname ?? name;

  factory QuickSendContact.fromBeneficiary(Map<String, dynamic> json) {
    final user = json['beneficiary_user'] as Map<String, dynamic>?
        ?? json['contact_user'] as Map<String, dynamic>?;

    return QuickSendContact(
      id: json['id'] as String,
      name: user?['full_name'] as String? ?? 'Unknown',
      phone: user?['phone'] as String?,
      profilePic: user?['profile_pic'] as String?,
      recipientId: user?['id'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      nickname: json['nickname'] as String?,
    );
  }

  /// From recent_recipients view
  factory QuickSendContact.fromRecentRecipient(Map<String, dynamic> json) {
    return QuickSendContact(
      id: json['beneficiary_id'] as String? ?? json['receiver_id'] as String,
      name: json['full_name'] as String? ?? 'Unknown',
      phone: json['phone'] as String?,
      profilePic: json['profile_pic'] as String?,
      recipientId: json['receiver_id'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      nickname: json['nickname'] as String?,
      transferCount: (json['transfer_count'] as num?)?.toInt() ?? 0,
      lastPaidAt: json['last_paid_at'] != null
          ? DateTime.parse(json['last_paid_at'] as String)
          : null,
    );
  }
}