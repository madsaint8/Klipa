import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/data/models/crypto/chart_data.dart';
import 'package:paywave/data/models/crypto/chart_period/chart_period.dart';
import 'package:paywave/data/models/crypto/crypto_coin.dart';
import 'package:paywave/data/repositories/crypto_repository.dart';
import 'package:paywave/services/coin_color_extractor.dart';
import 'package:paywave/services/coingecko_service.dart';

// ── Services / repository ─────────────────────────────────────────────────────

final coinGeckoServiceProvider = Provider<CoinGeckoService>((ref) {
  final service = CoinGeckoService(/* apiKey: 'CG-demo-key' */);
  ref.onDispose(service.dispose);
  return service;
});

final cryptoRepositoryProvider = Provider<CryptoRepository>(
  (ref) => CryptoRepository(ref.watch(coinGeckoServiceProvider)),
);

final coinColorMapProvider = Provider<Map<String, Color>>(
  (_) => CoinColorExtractor.brandColors,
);

// ── Trending coins: stale-while-revalidate ────────────────────────────────────
//
// 1. Cached coins are returned immediately (no spinner on app start).
// 2. If the cache is older than 3 min, a silent background refresh runs; the
//    UI only updates if something actually changed.
// 3. A failed refresh NEVER replaces good data with an error.
// 4. An error is only surfaced when there is nothing at all to show.
//
// Riverpod 3 auto-retries failed providers; we have our own backoff in the
// service, so automatic retries are disabled to avoid hammering the API.

final trendingCoinsProvider =
    AsyncNotifierProvider<TrendingCoinsNotifier, List<CryptoCoin>>(
  TrendingCoinsNotifier.new,
  retry: (_, __) => null,
);

class TrendingCoinsNotifier extends AsyncNotifier<List<CryptoCoin>> {
  @override
  Future<List<CryptoCoin>> build() async {
    final repo = ref.read(cryptoRepositoryProvider);
    final cached = await repo.readCachedCoins();
    if (cached != null && cached.coins.isNotEmpty) {
      if (cached.isStale) unawaited(refresh());
      return cached.coins;
    }
    return repo.fetchAndCacheCoins();
  }

  /// Silent refresh (also usable for pull-to-refresh).
  Future<void> refresh() async {
    try {
      final fresh = await ref.read(cryptoRepositoryProvider).fetchAndCacheCoins();
      if (!ref.mounted) return;
      if (!listEquals(state.value, fresh)) state = AsyncData(fresh);
    } catch (_) {
      // Keep whatever we already show.
    }
  }
}

/// Convenience selector so screens always see the freshest version of a coin.
final coinByIdProvider = Provider.family.autoDispose<CryptoCoin?, String>(
  (ref, id) => ref.watch(
    trendingCoinsProvider
        .select((a) => a.value?.where((c) => c.id == id).firstOrNull),
  ),
);

// ── Selected period (trending section) ────────────────────────────────────────
//
// ONE global value, not autoDispose and not per-coin. The old per-coin
// autoDispose provider reset to 1D whenever a card scrolled off-screen, which
// is why the section looked like it "behaved out of character".

class TrendingPeriodNotifier extends Notifier<ChartPeriod> {
  @override
  ChartPeriod build() => ChartPeriod.oneDay;

  void select(ChartPeriod period) => state = period;
}

final trendingPeriodProvider =
    NotifierProvider<TrendingPeriodNotifier, ChartPeriod>(
  TrendingPeriodNotifier.new,
);

// ── Chart data ────────────────────────────────────────────────────────────────

/// [detail] = true means the request comes from the detail screen: it jumps
/// the request queue and always loads full-resolution data.
typedef ChartKey = ({String coinId, ChartPeriod period, bool detail});

/// Network/disk-backed chart. All caching lives in [CryptoRepository]; this
/// provider only schedules a refresh when the data's TTL expires.
final chartProvider = FutureProvider.family<ChartData, ChartKey>(
  (ref, key) async {
    final repo = ref.watch(cryptoRepositoryProvider);
    final data = await repo.loadChart(
      key.coinId,
      key.period,
      highPriority: key.detail,
    );
    if (!ref.mounted) return data;

    // Re-evaluate when the TTL lapses (only does real work if still listened
    // to; otherwise it is recomputed lazily on next read).
    final timer = Timer(key.period.cacheTtl, ref.invalidateSelf);
    ref.onDispose(timer.cancel);
    return data;
  },
  retry: (_, __) => null,
);

/// What trending cards watch. For 1D/1W it is derived synchronously from the
/// sparkline already in the coin payload (zero API calls, no loading flash);
/// 1M/1Y fall through to [chartProvider].
final cardChartProvider = Provider.family<AsyncValue<ChartData>, ChartKey>(
  (ref, key) {
    final preview = ref.watch(sparklinePreviewProvider(key));
    if (preview != null) return AsyncData(preview);
    return ref.watch(chartProvider(key));
  },
);

/// Instant, network-free chart for 1D/1W built from the coin's 7-day
/// sparkline. Cards use it as their data; the detail screen shows it
/// immediately while the full-resolution chart loads (or if that fails).
/// Returns null for 1M/1Y or when the coin has no sparkline.
final sparklinePreviewProvider =
    Provider.family.autoDispose<ChartData?, ChartKey>((ref, key) {
  if (!key.period.hasSparkline) return null;
  final spark = ref.watch(
    trendingCoinsProvider.select(
      (a) => a.value?.where((c) => c.id == key.coinId).firstOrNull?.sparkline,
    ),
  );
  if (spark == null || spark.length < 8) return null;
  try {
    return ChartData.fromSparkline(spark, key.period);
  } catch (_) {
    return null;
  }
});