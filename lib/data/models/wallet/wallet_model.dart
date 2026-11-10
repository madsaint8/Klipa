class WalletModel {
  final String walletAddress;
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  WalletModel({
    required this.walletAddress,
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletAddress: json['wallet_address'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'ZAR',
      id: json['id'],
      userId: json['user_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}


