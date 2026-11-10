/// Pure formatting helpers (no Flutter imports -> unit-testable).
class MarketFormatters {
  MarketFormatters._();

  static String _group(String digits) => digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  /// 1234.5 -> R1,234.50   |   0.000123 -> R0.000123
  static String price(num? value) {
    if (value == null || !value.isFinite) return '—';
    final abs = value.abs();
    if (abs == 0) return 'R0.00';
    if (abs >= 1) {
      final parts = value.toStringAsFixed(2).split('.');
      return 'R${_group(parts[0])}.${parts[1]}';
    }
    return 'R${value.toStringAsFixed(abs >= 0.01 ? 4 : 6)}';
  }

  /// 1000 -> R1,000   |   12.5 -> R12.50
  static String amount(double value) {
    if (!value.isFinite) return '—';
    return value == value.roundToDouble()
        ? 'R${_group(value.round().toString())}'
        : price(value);
  }

  /// 1.234 -> +1.23%
  static String percent(double value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';
}
