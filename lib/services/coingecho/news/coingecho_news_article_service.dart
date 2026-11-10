import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../data/models/crypto/news/crypto_news_model.dart';

class CoinGeckoNewsService {
  // ── Use the Pro base when you have a key, public otherwise ────────────────
  // Pro:    https://pro-api.coingecko.com/api/v3
  // Public: https://api.coingecko.com/api/v3  (rate-limited, no /news)
  //
  // NOTE: /news is exclusive to Analyst, Lite, Pro, and Enterprise plans.
  // Set your key in the constructor or via env injection.
  static const _proBase = 'https://pro-api.coingecko.com/api/v3';

  final String? apiKey;

  const CoinGeckoNewsService({this.apiKey});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (apiKey != null && apiKey!.isNotEmpty)
          'x-cg-pro-api-key': apiKey!,
      };

  /// Fetches latest crypto news from CoinGecko /news
  ///
  /// [coinId]   — optional coin ID filter (e.g. 'bitcoin', 'ethereum')
  /// [page]     — 1–20
  /// [perPage]  — 1–20 (max 20 per CoinGecko docs)
  /// [language] — default 'en'
  /// [type]     — 'all' | 'news' | 'guides'
  Future<List<CryptoNewsArticle>> fetchNews({
    String? coinId,
    int page = 1,
    int perPage = 20,
    String language = 'en',
    String type = 'all',
  }) async {
    final params = <String, String>{
      'page': page.clamp(1, 20).toString(),
      'per_page': perPage.clamp(1, 20).toString(),
      'language': language,
      if (coinId != null && coinId.isNotEmpty) 'coin_id': coinId,
      if (coinId != null && coinId.isNotEmpty) 'type': type,
    };

    final uri = Uri.parse('$_proBase/news').replace(queryParameters: params);

    final res = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 401) {
      throw Exception('CoinGecko API key missing or invalid');
    }
    if (res.statusCode == 429) {
      throw Exception('CoinGecko rate limited — try again shortly');
    }
    if (res.statusCode != 200) {
      throw Exception('News fetch failed: ${res.statusCode}');
    }

    final dynamic decoded = json.decode(res.body);

    // /news returns a plain JSON array
    if (decoded is! List) {
      throw Exception('Unexpected news response: ${res.body.substring(0, 100)}');
    }

    return decoded
        .map((e) => CryptoNewsArticle.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}