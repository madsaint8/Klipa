import 'dart:async';

import '../repositories/market_catalog_repository.dart';

/// Never surface raw exception text (it can leak URLs, keys or internals).
String marketErrorMessage(Object error) {
  if (error is MarketException) return error.message;
  if (error is TimeoutException) {
    return 'The request timed out. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}
