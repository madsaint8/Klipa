/// Selectable chart time ranges.
///
/// [cacheTtl] is how long fetched chart data is considered fresh. Short ranges
/// change quickly so they expire sooner; long ranges barely move, so we avoid
/// hitting the API for them.
enum ChartPeriod {
  oneDay(
    label: '1D',
    longLabel: '1 Day',
    spanLabel: '24 hours',
    days: '1',
    cacheTtl: Duration(minutes: 5),
  ),
  oneWeek(
    label: '1W',
    longLabel: '1 Week',
    spanLabel: '7 days',
    days: '7',
    cacheTtl: Duration(minutes: 15),
  ),
  oneMonth(
    label: '1M',
    longLabel: '1 Month',
    spanLabel: '30 days',
    days: '30',
    cacheTtl: Duration(hours: 1),
  ),
  oneYear(
    label: '1Y',
    longLabel: '1 Year',
    spanLabel: '12 months',
    days: '365',
    cacheTtl: Duration(hours: 6),
  );

  const ChartPeriod({
    required this.label,
    required this.longLabel,
    required this.spanLabel,
    required this.days,
    required this.cacheTtl,
  });

  final String label;
  final String longLabel;
  final String spanLabel;
  final String days;
  final Duration cacheTtl;

  /// 1D and 1W can be drawn from the 7-day hourly sparkline that already
  /// ships with the markets request, so trending cards need zero extra calls.
  bool get hasSparkline => this == oneDay || this == oneWeek;

  /// Number of hourly sparkline points that make up this period.
  int get sparklinePoints => this == oneDay ? 24 : 168;
}