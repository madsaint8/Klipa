/// Central place for every tunable number in the cards feature.
class CardLimits {
  CardLimits._();

  static const int maxVirtualCards = 5;
  static const int maxLabelLength = 24;
  static const double minSpendingLimit = 100;
  static const double maxSpendingLimit = 50000;

  /// Network calls are abandoned after this long (shows an error, never hangs).
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Card number / CVV are auto-hidden after this long.
  static const Duration secretsTtl = Duration(seconds: 30);
}