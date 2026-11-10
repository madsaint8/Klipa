import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/data/models/crypto/news/crypto_news_model.dart';
import 'package:paywave/providers/crypto/crypto_provider.dart';
import 'package:paywave/providers/equities/equities_provider.dart';
import 'package:paywave/providers/news/news_provider.dart';
import 'package:paywave/providers/sites/sites_provider.dart';

import '../logic/market_adapters.dart';
import '../logic/market_limits.dart';
import '../logic/market_search_logic.dart';
import '../models/market_item_model.dart';
import '../models/market_tab_model.dart';
import 'market_catalog_provider.dart';
import 'market_search_provider.dart';

/// Raw (unfiltered) items for a section, mapped to [MarketItem].
/// All data keeps coming from your existing providers — nothing refetches.
final marketSourceProvider = Provider.autoDispose
    .family<AsyncValue<List<MarketItem>>, MarketTab>((ref, tab) {
  switch (tab) {
    case MarketTab.tokens:
      // TODO: swap for a full coin-list provider to search ALL coins,
      // not just trending ones.
      return ref.watch(trendingCoinsProvider).whenData(
          (coins) => [for (final c in coins) MarketAdapters.fromCoin(c)]);
    case MarketTab.equities:
      return ref.watch(equitiesProvider).whenData(
          (list) => [for (final e in list) MarketAdapters.fromEquity(e)]);
    case MarketTab.defi:
      return ref.watch(topProtocolsProvider).whenData(
          (list) => [for (final s in list) MarketAdapters.fromSite(s)]);
    case MarketTab.rwas:
      return ref.watch(rwasProvider);
    case MarketTab.insurance:
      return ref.watch(insuranceProvider);
    case MarketTab.services:
      return ref.watch(servicesProvider);
    case MarketTab.discover:
    case MarketTab.news:
      return const AsyncData(<MarketItem>[]);
  }
});

/// A section's items, filtered by the debounced search query.
/// Empty query = everything. In-memory only: typing never hits the network.
final marketTabItemsProvider = Provider.autoDispose
    .family<AsyncValue<List<MarketItem>>, MarketTab>((ref, tab) {
  final query = ref.watch(marketSearchProvider.select((s) => s.committed));
  return ref
      .watch(marketSourceProvider(tab))
      .whenData((items) => MarketSearchLogic.filter(items, query));
});

/// Latest news normally; live search results while a query is active.
final marketNewsProvider =
    Provider.autoDispose<AsyncValue<List<CryptoNewsArticle>>>((ref) {
  final query = ref.watch(marketSearchProvider.select((s) => s.committed));
  return query.isEmpty
      ? ref.watch(latestNewsProvider)
      : ref.watch(newsSearchResultsProvider(query));
});

/// Result counts per tab, shown as badges on the tab bar while searching.
final marketTabCountsProvider =
    Provider.autoDispose<Map<MarketTab, int>>((ref) {
  final active = ref.watch(marketSearchProvider.select((s) => s.isActive));
  if (!active) return const {};

  final counts = <MarketTab, int>{};
  for (final tab in MarketTab.catalogTabs) {
    final list = ref.watch(marketTabItemsProvider(tab)).value;
    if (list != null) counts[tab] = list.length;
  }
  final news = ref.watch(marketNewsProvider).value;
  if (news != null) counts[MarketTab.news] = news.length;

  counts[MarketTab.discover] = counts.values.fold(0, (a, b) => a + b);
  return counts;
});

/// Pull-to-refresh / retry. Throttled so rate-limited APIs aren't hammered.
final marketRefresherProvider =
    Provider<MarketRefresher>((ref) => MarketRefresher(ref));

class MarketRefresher {
  MarketRefresher(this._ref);

  final Ref _ref;
  final Map<MarketTab, DateTime> _last = {};

  Future<void> refresh(MarketTab tab, {bool force = false}) async {
    final now = DateTime.now();
    final last = _last[tab];
    if (!force &&
        last != null &&
        now.difference(last) < MarketLimits.refreshCooldown) {
      return;
    }
    _last[tab] = now;

    if (tab == MarketTab.discover) {
      await Future.wait([
        for (final t in MarketTab.values)
          if (t != MarketTab.discover) _refreshOne(t),
      ]);
    } else {
      await _refreshOne(tab);
    }
  }

  Future<void> _refreshOne(MarketTab tab) async {
    try {
      switch (tab) {
        case MarketTab.tokens:
          _ref.invalidate(trendingCoinsProvider);
          await Future<void>.delayed(const Duration(milliseconds: 600));
        case MarketTab.equities:
          _ref.invalidate(equitiesProvider);
          await _ref.read(equitiesProvider.future);
        case MarketTab.defi:
          _ref.invalidate(topProtocolsProvider);
          await _ref.read(topProtocolsProvider.future);
        case MarketTab.rwas:
          _ref.invalidate(rwasProvider);
          await _ref.read(rwasProvider.future);
        case MarketTab.insurance:
          _ref.invalidate(insuranceProvider);
          await _ref.read(insuranceProvider.future);
        case MarketTab.services:
          _ref.invalidate(servicesProvider);
          await _ref.read(servicesProvider.future);
        case MarketTab.news:
          _ref.invalidate(latestNewsProvider);
          _ref.invalidate(newsSearchResultsProvider);
          await _ref.read(latestNewsProvider.future);
        case MarketTab.discover:
          break;
      }
    } catch (_) {
      // The providers expose the error state; the UI shows a retry.
    }
  }
}
