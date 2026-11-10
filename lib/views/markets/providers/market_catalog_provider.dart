import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/market_limits.dart';
import '../models/market_item_model.dart';
import 'market_repository_provider.dart';

// Cached (not autoDispose): switching tabs never refetches.
final rwasProvider = FutureProvider<List<MarketItem>>((ref) => ref
    .read(marketCatalogRepositoryProvider)
    .fetchRwas()
    .timeout(MarketLimits.requestTimeout));

final insuranceProvider = FutureProvider<List<MarketItem>>((ref) => ref
    .read(marketCatalogRepositoryProvider)
    .fetchInsurance()
    .timeout(MarketLimits.requestTimeout));

final servicesProvider = FutureProvider<List<MarketItem>>((ref) => ref
    .read(marketCatalogRepositoryProvider)
    .fetchServices()
    .timeout(MarketLimits.requestTimeout));
