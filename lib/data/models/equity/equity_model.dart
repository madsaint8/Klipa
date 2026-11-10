class Equity {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double? volume;
  final double? marketCap;
  final String? logoUrl;
  final String exchange;

  const Equity({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    this.volume,
    this.marketCap,
    this.logoUrl,
    required this.exchange,
  });

  /// Alpha Vantage GLOBAL_QUOTE shape
  factory Equity.fromAlphaVantage(
      String symbol, String name, Map<String, dynamic> quote) {
    final q = quote['Global Quote'] as Map<String, dynamic>? ?? {};
    return Equity(
      symbol: symbol,
      name: name,
      price: double.tryParse(q['05. price'] as String? ?? '0') ?? 0,
      change: double.tryParse(q['09. change'] as String? ?? '0') ?? 0,
      changePercent: double.tryParse(
              (q['10. change percent'] as String? ?? '0%').replaceAll('%', '')) ??
          0,
      volume: double.tryParse(q['06. volume'] as String? ?? '0') ?? 0,
      exchange: 'NASDAQ',
    );
  }

  /// Fallback constructor for when you have raw values already
  factory Equity.fromValues({
    required String symbol,
    required String name,
    required double price,
    required double change,
    required double changePercent,
    double? volume,
    double? marketCap,
    String? logoUrl,
    String exchange = 'NASDAQ',
  }) {
    return Equity(
      symbol: symbol,
      name: name,
      price: price,
      change: change,
      changePercent: changePercent,
      volume: volume,
      marketCap: marketCap,
      logoUrl: logoUrl,
      exchange: exchange,
    );
  }

  bool get isPositive => changePercent >= 0;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

  String get formattedVolume {
    if (volume == null) return '—';
    final v = volume!;
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}