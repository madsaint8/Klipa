// import '../../transaction_type.dart';

// class TransactionRecord {
//   final String id;
//   final double amount;
//   final String currency;
//   final TransactionCategory category;
//   final String description;
//   final DateTime completedAt;
//   final bool isCredit; // true = money in, false = money out
//   final String? counterpartyName; // who sent/received

//   const TransactionRecord({
//     required this.id,
//     required this.amount,
//     required this.currency,
//     required this.category,
//     required this.description,
//     required this.completedAt,
//     required this.isCredit,
//     this.counterpartyName,
//   });

//   String get formattedAmount =>
//       '${isCredit ? '+' : '-'}${currency} ${amount.toStringAsFixed(2)}';

//   factory TransactionRecord.fromJson(Map<String, dynamic> json) {
//     final txType = json['transaction_type'] as String?;
//     final type = json['type'] as String?;
//     final isCredit = txType == 'credit';

//     return TransactionRecord(
//       id: json['id'] as String,
//       amount: (json['amount'] as num).toDouble(),
//       currency: json['currency'] as String? ?? 'ZAR',
//       category: TransactionCategoryX.fromString(type, txType),
//       description: json['description'] as String? ?? '',
//       completedAt: DateTime.parse(
//           json['completed_at'] as String? ??
//               json['created_at'] as String),
//       isCredit: isCredit,
//       counterpartyName: isCredit
//           ? json['sender_name'] as String?
//           : json['receiver_name'] as String?,
//     );
//   }
// }