import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Parsed payment payload from a QR code.
/// Supports three wire formats:
///   1. Pipe-delimited  → PAY|merchantId|merchantName|amount|currency
///   2. URL query params → https://pay.example.com?mid=X&name=Y&amount=Z&currency=W
///   3. Fallback        → raw string treated as merchant name
///
/// Adapt to your payment standard (UPI, EMVCo, ISO 20022, etc.)
class PaymentPayload {
  final String rawValue;
  final String? merchantName;
  final String? merchantId;
  final double? amount;
  final String currency;
  final String? reference;
  final String transactionId;

  const PaymentPayload({
    required this.rawValue,
    this.merchantName,
    this.merchantId,
    this.amount,
    this.currency = 'ZAR',
    this.reference,
    required this.transactionId,
  });

  factory PaymentPayload.fromRaw(String raw) {
    final id = const Uuid().v4();

    // Format 1 – pipe-delimited
    if (raw.startsWith('PAY|')) {
      final parts = raw.split('|');
      return PaymentPayload(
        rawValue: raw,
        merchantId: parts.length > 1 ? parts[1] : null,
        merchantName: parts.length > 2 ? parts[2] : 'Merchant',
        amount: parts.length > 3 ? double.tryParse(parts[3]) : null,
        currency: parts.length > 4 ? parts[4] : 'ZAR',
        transactionId: id,
      );
    }

    // Format 2 – URL
    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme) {
      return PaymentPayload(
        rawValue: raw,
        merchantId: uri.queryParameters['mid'],
        merchantName: uri.queryParameters['name'] ?? uri.host,
        amount: double.tryParse(uri.queryParameters['amount'] ?? ''),
        currency: uri.queryParameters['currency'] ?? 'ZAR',
        reference: uri.queryParameters['ref'],
        transactionId: id,
      );
    }

    // Format 3 – fallback
    return PaymentPayload(
      rawValue: raw,
      merchantName: raw.length > 40 ? '${raw.substring(0, 40)}...' : raw,
      transactionId: id,
    );
  }

  String get displayAmount {
    if (amount == null) return '--';
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  String get formattedTime =>
      DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now());
}