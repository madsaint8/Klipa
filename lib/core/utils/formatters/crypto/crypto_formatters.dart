import 'package:paywave/data/models/crypto/chart_period/chart_period.dart';

/// Single source of truth for number/date formatting (previously duplicated in
/// CryptoCard and CoinDetailScreen).

String _group(String digits) =>
    digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');

/// 1 234 567,89 style for large values, extra precision for sub-unit coins.
String formatPrice(double v) {
  if (!v.isFinite) return '—';
  final a = v.abs();
  if (a >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
  if (a >= 1000) {
    final p = v.toStringAsFixed(2).split('.');
    return '${_group(p[0])},${p[1]}';
  }
  if (a >= 1) return v.toStringAsFixed(2);
  if (a >= 0.01) return v.toStringAsFixed(4);
  if (a == 0) return '0.00';
  return v.toStringAsFixed(6);
}

String formatCompact(double n) {
  if (!n.isFinite) return '—';
  if (n >= 1e12) return '${(n / 1e12).toStringAsFixed(2)}T';
  if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)}B';
  if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}M';
  if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(2)}K';
  return n.toStringAsFixed(2);
}

String formatSignedPercent(double v) =>
    '${v >= 0 ? '+' : '-'}${v.abs().toStringAsFixed(2)}%';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Tooltip timestamp, with detail appropriate to the selected period.
String formatChartTime(DateTime t, ChartPeriod period) {
  String two(int n) => n.toString().padLeft(2, '0');
  final hm = '${two(t.hour)}:${two(t.minute)}';
  switch (period) {
    case ChartPeriod.oneDay:
      return hm;
    case ChartPeriod.oneWeek:
      return '${_days[t.weekday - 1]} $hm';
    case ChartPeriod.oneMonth:
      return '${t.day} ${_months[t.month - 1]}';
    case ChartPeriod.oneYear:
      return '${t.day} ${_months[t.month - 1]} ${t.year}';
  }
}