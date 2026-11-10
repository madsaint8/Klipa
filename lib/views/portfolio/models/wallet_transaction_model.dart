enum TransactionType {
  receive,
  send,
  swap,
  buy,
  sell,
}

class WalletTransaction {
  final String hash;
  final TransactionType type;
  final String token;
  final double amount;
  final DateTime timestamp;
  final String from;
  final String to;

  const WalletTransaction({
    required this.hash,
    required this.type,
    required this.token,
    required this.amount,
    required this.timestamp,
    required this.from,
    required this.to,
  });
}