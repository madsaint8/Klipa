import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/equity/equity_model.dart';
import '../../services/equitie_service.dart';



// ─────────────────────────────────────────────────────────────────────────────
// IMPORTANT: Replace 'YOUR_ALPHA_VANTAGE_KEY' with your actual key.
// Free key: https://www.alphavantage.co/support/#api-key
// Free tier limit: 25 requests / day
// ─────────────────────────────────────────────────────────────────────────────
const _alphaVantageKey = 'ALPHA_VANTAGE_KEY';

// ── Service singleton ─────────────────────────────────────────────────────────
final equityServiceProvider = Provider<EquityService>(
  (_) => const EquityService(apiKey: _alphaVantageKey),
);

// ── Full watchlist fetch ──────────────────────────────────────────────────────
final equitiesProvider = FutureProvider<List<Equity>>((ref) {
  return ref.read(equityServiceProvider).fetchWatchlist();
});

// ── Equities filtered by search query ────────────────────────────────────────
final equitiesSearchQueryProvider = StateProvider<String>((_) => '');

final filteredEquitiesProvider =
    FutureProvider.autoDispose<List<Equity>>((ref) {
  final query = ref.watch(equitiesSearchQueryProvider).trim();

  return ref
      .read(equityServiceProvider)
      .fetchWatchlist()
      .then((all) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all
        .where((e) =>
            e.symbol.toLowerCase().contains(q) ||
            e.name.toLowerCase().contains(q))
        .toList();
  });
});

// ── Single equity quote ───────────────────────────────────────────────────────
final equityQuoteProvider =
    FutureProvider.autoDispose.family<Equity, ({String symbol, String name})>(
  (ref, entry) => ref
      .read(equityServiceProvider)
      .fetchQuote(entry.symbol, entry.name),
);