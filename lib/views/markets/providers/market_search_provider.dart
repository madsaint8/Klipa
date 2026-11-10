import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/data/models/crypto/news/crypto_news_model.dart';
import 'package:paywave/providers/news/news_provider.dart';

import '../logic/market_limits.dart';
import '../logic/market_search_logic.dart';
import '../models/market_search_model.dart';

/// ONE source of truth for the search text.
///
/// This replaces the old fan-out that pushed the query into four separate
/// providers (and made each re-hit its API on every keystroke — which burns
/// rate-limited keys like Alpha Vantage's 25 requests/day). Now every section
/// filters already-loaded data using the debounced `committed` value.
class MarketSearchNotifier extends Notifier<MarketSearchState> {
  Timer? _timer;

  @override
  MarketSearchState build() {
    ref.onDispose(() => _timer?.cancel());
    return const MarketSearchState();
  }

  /// Every keystroke: update the field instantly, filter after the debounce.
  void update(String text) {
    _timer?.cancel();
    final clean = text.length > MarketLimits.maxQueryLength
        ? text.substring(0, MarketLimits.maxQueryLength)
        : text;

    if (clean.trim().isEmpty) {
      state = MarketSearchState(raw: clean); // clearing is instant
      return;
    }
    state = state.copyWith(raw: clean);
    _timer = Timer(MarketLimits.searchDebounce, () {
      if (!ref.mounted) return;
      state = state.copyWith(committed: clean.trim());
    });
  }

  /// Suggestion chips / keyboard "search": commit immediately.
  void submit(String text) {
    _timer?.cancel();
    final clean = text.trim().length > MarketLimits.maxQueryLength
        ? text.trim().substring(0, MarketLimits.maxQueryLength)
        : text.trim();
    state = MarketSearchState(raw: clean, committed: clean);
  }

  void clear() {
    _timer?.cancel();
    state = const MarketSearchState();
  }
}

final marketSearchProvider =
    NotifierProvider.autoDispose<MarketSearchNotifier, MarketSearchState>(
  MarketSearchNotifier.new,
);

/// Live news search. Falls back to filtering the already-loaded latest news
/// if the API fails or the query is too short, so search never dead-ends.
/// Results are cached for 2 minutes so retyping a query is instant.
final newsSearchResultsProvider = FutureProvider.autoDispose
    .family<List<CryptoNewsArticle>, String>((ref, query) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 2), link.close);
  ref.onDispose(timer.cancel);

  if (query.length >= MarketLimits.newsApiMinChars) {
    try {
      return await ref
          .read(freeNewsServiceProvider)
          .fetchNews(query: query, pageSize: 10)
          .timeout(MarketLimits.requestTimeout);
    } catch (_) {
      // fall through to the local filter below
    }
  }
  final latest = await ref.watch(latestNewsProvider.future);
  return MarketSearchLogic.filterNews(latest, query);
});
