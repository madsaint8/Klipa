/// Every tunable number for the marketplace in one place.
class MarketLimits {
  MarketLimits._();

  /// Wait this long after the last keystroke before filtering / searching.
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// Live news API search only starts at this many characters
  /// (below that we filter already-loaded news locally).
  static const int newsApiMinChars = 3;

  static const int maxQueryLength = 64;

  /// Per-section rows shown in the grouped "All" search view.
  static const int rowsPerSectionInAll = 4;

  static const double maxPurchase = 100000;

  static const Duration requestTimeout = Duration(seconds: 15);

  /// Pull-to-refresh is ignored if the same tab refreshed more recently
  /// (protects rate-limited APIs such as Alpha Vantage's 25 req/day).
  static const Duration refreshCooldown = Duration(seconds: 30);

  static const List<String> searchSuggestions = [
    'Gold',
    'Bitcoin',
    'Travel',
    'Airtime',
    'Real estate',
    'Treasury',
  ];
}
