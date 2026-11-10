import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/equity/equity_model.dart';

/// Alpha Vantage free tier: 25 requests/day, no credit card needed.
/// Get your key at https://www.alphavantage.co/support/#api-key
///
/// To use: replace [apiKey] with your key, or pass it via constructor.
///
/// If you prefer a different provider, swap this service — the Riverpod
/// provider depends only on [EquityService], so no other files change.
class EquityService {
  final String apiKey;
  static const _base = 'https://www.alphavantage.co/query';

  /// Default watchlist shown in the Equities tab
  static const defaultWatchlist = <({String symbol, String name})>[
    (symbol: 'AAPL', name: 'Apple'),
    (symbol: 'MSFT', name: 'Microsoft'),
    (symbol: 'NVDA', name: 'NVIDIA'),
    (symbol: 'TSLA', name: 'Tesla'),
    (symbol: 'GOOGL', name: 'Alphabet'),
    (symbol: 'AMZN', name: 'Amazon'),
    (symbol: 'META', name: 'Meta'),
    (symbol: 'BRK.B', name: 'Berkshire'),
  ];

  const EquityService({required this.apiKey});

  /// Fetches a single GLOBAL_QUOTE for [symbol].
  Future<Equity> fetchQuote(String symbol, String name) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'function': 'GLOBAL_QUOTE',
      'symbol': symbol,
      'apikey': apiKey,
    });

    final res = await http.get(uri).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Equity fetch failed for $symbol: ${res.statusCode}');
    }

    final body = json.decode(res.body) as Map<String, dynamic>;

    // Alpha Vantage wraps throttled responses in {"Note": "..."}
    if (body.containsKey('Note') || body.containsKey('Information')) {
      throw Exception('Alpha Vantage rate limit hit — free tier: 25 req/day');
    }

    return Equity.fromAlphaVantage(symbol, name, body);
  }

  /// Fetches the full default watchlist concurrently.
  /// On rate-limit, throws so the Riverpod provider goes to error state.
  Future<List<Equity>> fetchWatchlist(
      [List<({String symbol, String name})>? watchlist]) async {
    final list = watchlist ?? defaultWatchlist;

    // Stagger requests slightly to avoid burst rate-limiting
    final results = <Equity>[];
    for (final entry in list) {
      final equity = await fetchQuote(entry.symbol, entry.name);
      results.add(equity);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return results;
  }
}