import '../../constants/transaction_category/transaction_category.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String? walletId;
  final String? senderId;
  final String? receiverId;
  final double amount;
  final String currency;
  final String status;
  final String type;
  final String transactionType;
  final String? description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? senderName;
  final String? senderPic;
  final String? receiverName;
  final String? receiverPic;
  final String? currentUserId;
  final TransactionCategory category;

  TransactionModel({
    required this.id,
    required this.userId,
    this.walletId,
    this.senderId,
    this.receiverId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.type,
    required this.transactionType,
    this.description,
    required this.createdAt,
    this.completedAt,
    this.senderName,
    this.senderPic,
    this.receiverName,
    this.receiverPic,
    this.currentUserId,
  }) : category = TransactionCategoryX.fromString(type, transactionType);

  // Is the current user receiving this?
  bool get isCredit => transactionType == 'credit';

  bool get isDebit => !isCredit;
  bool get isCompleted => status == 'completed';

  // Show the OTHER person's name
  String get counterpartyName {
    if (currentUserId == senderId) {
      return receiverName ?? 'Unknown';
    }
    return senderName ?? 'Unknown';
  }

  // Show the OTHER person's profile pic
  String? get counterpartyPic {
    if (currentUserId == senderId) return receiverPic;
    return senderPic;
  }

  String get formattedAmount =>
      '${isCredit ? '+' : '-'}R ${amount.toStringAsFixed(2)}';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final txType = json['transaction_type'] as String?;
    final type = json['type'] as String? ?? 'transfer';
    final currentUserId = json['current_user_id'] as String?;
    final receiverId = json['receiver_id'] as String?;

    // Prefer the row's own type; only fall back to IDs if it's missing
    final isCredit = txType != null
        ? txType == 'credit'
        : (currentUserId != null && receiverId == currentUserId);

    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      walletId: json['wallet_id'] as String?,
      senderId: json['sender_id'] as String?,
      receiverId: receiverId,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ZAR',
      status: json['status'] as String? ?? '',
      type: type,
      transactionType: isCredit ? 'credit' : 'debit',
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      senderName: json['sender_name'] as String?,
      senderPic: json['sender_pic'] as String?,
      receiverName: json['receiver_name'] as String?,
      receiverPic: json['receiver_pic'] as String?,
      currentUserId: currentUserId,
    );
  }
}
