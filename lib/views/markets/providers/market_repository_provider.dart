import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/market_catalog_repository.dart';

/// TODO: return real backend repository (or override in main/tests).
final marketCatalogRepositoryProvider = Provider<MarketCatalogRepository>(
  (ref) => MockMarketCatalogRepository(),
);
