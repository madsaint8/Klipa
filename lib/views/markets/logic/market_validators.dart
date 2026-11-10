import '../models/market_item_model.dart';
import 'market_formatters.dart';
import 'market_limits.dart';

class MarketValidators {
  MarketValidators._();

  static double? parseAmount(String? value) {
    final n = double.tryParse((value ?? '').replaceAll(',', '').trim());
    return (n != null && n.isFinite) ? n : null;
  }

  static String? amountText(MarketItem item, String? value) {
    final n = parseAmount(value);
    if (n == null) return 'Enter a valid amount';
    return amount(item, n);
  }

  static String? amount(MarketItem item, double n) {
    if (!n.isFinite || n <= 0) return 'Enter a valid amount';
    if (n < item.minAmount) {
      return 'Minimum is ${MarketFormatters.amount(item.minAmount)}';
    }
    if (n > MarketLimits.maxPurchase) {
      return 'Maximum is ${MarketFormatters.amount(MarketLimits.maxPurchase)}';
    }
    return null;
  }
}
