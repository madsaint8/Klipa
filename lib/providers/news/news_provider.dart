import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/crypto/news/crypto_news_model.dart';
import '../../services/news/free_news_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// API KEY — from FreeNewsAPI documentation examples (prototype only).
// Sign up for your own key at https://freenewsapi.io
// ─────────────────────────────────────────────────────────────────────────────
const _freeNewsApiKey =
    '5935a24f0a90be7036432c259750dae924a6cb5b694bb841dc0efcabb38b57b4';

// ── Service singleton ─────────────────────────────────────────────────────────
final freeNewsServiceProvider = Provider<FreeNewsService>(
  (_) => const FreeNewsService(apiKey: _freeNewsApiKey),
);

// ── Search / filter queries ───────────────────────────────────────────────────

/// Text typed in the search bar — used for client-side filtering of fetched results.
final newsSearchQueryProvider = StateProvider<String>((_) => '');

/// Optional topic filter passed to the API (e.g. 'business', 'technology').
final newsTopicFilterProvider = StateProvider<String?>((_) => null);

/// Token/coin search query — watched by coin list widgets to filter CoinGecko results.
final tokenSearchQueryProvider = StateProvider<String>((_) => '');

// ── Latest news ───────────────────────────────────────────────────────────────
/// Fetches crypto-focused news once on mount.
/// Used by Stream tab. Invalidate to refresh.
final latestNewsProvider =
    FutureProvider.autoDispose<List<CryptoNewsArticle>>((ref) {
  return ref
      .read(freeNewsServiceProvider)
      .fetchCryptoNews(pageSize: 20);
});

// ── Topic-scoped news ─────────────────────────────────────────────────────────
/// Re-fetches when [newsTopicFilterProvider] changes.
final topicNewsProvider =
    FutureProvider.autoDispose<List<CryptoNewsArticle>>((ref) {
  final topic = ref.watch(newsTopicFilterProvider);
  return ref
      .read(freeNewsServiceProvider)
      .fetchNews(topic: topic, pageSize: 20);
});

// ── Client-side filtered news ─────────────────────────────────────────────────
/// Watches [newsSearchQueryProvider] and filters [latestNewsProvider] in-memory.
/// If the query looks like a topic keyword it also passes it to the API.
final filteredNewsProvider =
    FutureProvider.autoDispose<List<CryptoNewsArticle>>((ref) async {
  final query = ref.watch(newsSearchQueryProvider).trim();

  // If search is active, do a live API search for better results
  if (query.length >= 3) {
    return ref
        .read(freeNewsServiceProvider)
        .fetchNews(query: query, pageSize: 20);
  }

  // Otherwise filter the already-fetched latest news client-side
  final all = await ref.watch(latestNewsProvider.future);
  if (query.isEmpty) return all;

  final q = query.toLowerCase();
  return all.where((a) {
    return a.title.toLowerCase().contains(q) ||
        a.publisher.toLowerCase().contains(q) ||
        a.topics.any((t) => t.toLowerCase().contains(q));
  }).toList();
});

// ── Article detail ────────────────────────────────────────────────────────────
/// Fetches full article (thumbnail + body) for a given UUID.
/// Use this when tapping a news card to show the full article.
final articleDetailProvider =
    FutureProvider.autoDispose.family<CryptoNewsArticle, String>(
  (ref, uuid) => ref.read(freeNewsServiceProvider).fetchDetails(uuid),
);




























// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import '../../data/models/crypto/news/crypto_news_model.dart';
// import '../../services/coingecho/news/coingecho_news_article_service.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // API KEY
// // CoinGecko /news requires an Analyst plan or above.
// // Get yours at https://www.coingecko.com/en/api/pricing
// // Replace the string below, or inject it via --dart-define / flavors:
// //   flutter run --dart-define=CG_KEY=your_key_here
// // ─────────────────────────────────────────────────────────────────────────────
// const _cgKey = String.fromEnvironment('CG_KEY', defaultValue: 'CG-DEMO_KEY_REPLACE_ME');

// // ── Service singleton ─────────────────────────────────────────────────────────
// final coinGeckoNewsServiceProvider = Provider<CoinGeckoNewsService>(
//   (_) => CoinGeckoNewsService(apiKey: _cgKey),
// );

// // ── Search / filter query ─────────────────────────────────────────────────────
// /// Text typed in the Markets search bar — filtered client-side after fetch.
// final newsSearchQueryProvider = StateProvider<String>((_) => '');

// /// CoinGecko coin_id to scope /news to one token (e.g. 'bitcoin').
// /// Set this when a user taps a token row.
// final tokenNewsFilterProvider = StateProvider<String?>((_) => null);

// // ── Token search query (coin list filtering) ──────────────────────────────────
// /// Raw text query for filtering the CoinGecko coins list client-side.
// /// MarketsNotifier writes here whenever the search bar changes.
// final tokenSearchQueryProvider = StateProvider<String>((_) => '');

// // ── Latest news (no coin filter) ─────────────────────────────────────────────
// /// Used by Stream tab. Fetched once on mount; invalidate to refresh.
// final latestNewsProvider =
//     FutureProvider.autoDispose<List<CryptoNewsArticle>>((ref) {
//   return ref
//       .read(coinGeckoNewsServiceProvider)
//       .fetchNews(perPage: 20);
// });

// // ── Coin-scoped news ──────────────────────────────────────────────────────────
// /// Re-fetches automatically when [tokenNewsFilterProvider] changes.
// final coinNewsProvider =
//     FutureProvider.autoDispose<List<CryptoNewsArticle>>((ref) {
//   final coinId = ref.watch(tokenNewsFilterProvider);
//   return ref
//       .read(coinGeckoNewsServiceProvider)
//       .fetchNews(coinId: coinId, perPage: 20);
// });

// // ── Client-side filtered news ─────────────────────────────────────────────────
// /// Watches [newsSearchQueryProvider] and filters the latest news in-memory.
// /// No extra network call — just re-filters the cached fetch.
// final filteredNewsProvider =
//     FutureProvider.autoDispose<List<CryptoNewsArticle>>((ref) async {
//   final query = ref.watch(newsSearchQueryProvider).trim().toLowerCase();
//   final all   = await ref.watch(latestNewsProvider.future);

//   if (query.isEmpty) return all;

//   return all.where((a) {
//     return a.title.toLowerCase().contains(query) ||
//         a.sourceName.toLowerCase().contains(query) ||
//         a.relatedCoinIds.any((id) => id.toLowerCase().contains(query));
//   }).toList();
// });