import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:paywave/data/models/crypto/chart_period/chart_period.dart';
import 'package:paywave/data/models/crypto/crypto_coin.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.retryable = false});
  final String message;
  final int? statusCode;
  final bool retryable;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thin, resilient CoinGecko client.
///
/// * Timeouts on every request.
/// * Retries 429 / 5xx / network errors with exponential backoff + jitter.
/// * Honors `Retry-After` and applies a **global cooldown** after a 429 so
///   other queued requests don't keep hammering a rate-limited API.
///
/// Pass [apiKey] (a free "demo" key) to get noticeably higher rate limits.
class CoinGeckoService {
  CoinGeckoService({
    http.Client? client,
    this.currency = 'zar',
    this.apiKey,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String currency;
  final String? apiKey;

  static const _host = 'api.coingecko.com';
  static const _basePath = '/api/v3';
  static const _timeout = Duration(seconds: 10);
  static const _maxAttempts = 2;

  DateTime _cooldownUntil = DateTime.fromMillisecondsSinceEpoch(0);
  final _rng = math.Random();

  void dispose() => _client.close();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Trending coins enriched with market data + 7d hourly sparkline.
  Future<List<CryptoCoin>> fetchTrendingCoins({int limit = 10}) async {
    final trendingRes = await _get(_uri('/search/trending', const {}));
    final decoded = jsonDecode(trendingRes.body);
    final ids = <String>[
      if (decoded is Map && decoded['coins'] is List)
        for (final c in decoded['coins'] as List)
          if (c is Map && c['item'] is Map && c['item']['id'] is String)
            c['item']['id'] as String,
    ].take(limit).toList();

    final query = <String, String>{
      'vs_currency': currency,
      'order': 'market_cap_desc',
      'sparkline': 'true',
      'price_change_percentage': '24h',
      if (ids.isNotEmpty) 'ids': ids.join(',') else ...{
        'per_page': '$limit',
        'page': '1',
      },
    };
    final marketsRes = await _get(_uri('/coins/markets', query));
    final list = jsonDecode(marketsRes.body);
    if (list is! List) throw const FormatException('Unexpected markets response');

    final coins = list.map(CryptoCoin.tryParse).whereType<CryptoCoin>().toList();
    if (ids.isNotEmpty) {
      // Preserve CoinGecko's trending order.
      coins.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
    }
    return coins;
  }

  /// Raw price series for one coin/period (x = epoch ms).
  Future<List<FlSpot>> fetchChartSpots(String coinId, ChartPeriod period) async {
    final res = await _get(_uri('/coins/$coinId/market_chart', {
      'vs_currency': currency,
      'days': period.days,
    }));
    final body = jsonDecode(res.body);
    final prices = body is Map ? body['prices'] : null;
    if (prices is! List) throw const FormatException('Unexpected chart response');

    final spots = <FlSpot>[];
    for (final p in prices) {
      if (p is List && p.length >= 2 && p[0] is num && p[1] is num) {
        spots.add(FlSpot((p[0] as num).toDouble(), (p[1] as num).toDouble()));
      }
    }
    return spots;
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  Uri _uri(String path, Map<String, String> query) =>
      Uri.https(_host, '$_basePath$path', query.isEmpty ? null : query);

  Future<http.Response> _get(Uri uri) async {
    var attempt = 0;
    while (true) {
      attempt++;

      final wait = _cooldownUntil.difference(DateTime.now());
      if (!wait.isNegative) await Future<void>.delayed(wait);

      try {
        final res = await _client.get(uri, headers: {
          'accept': 'application/json',
          if (apiKey != null) 'x-cg-demo-api-key': apiKey!,
        }).timeout(_timeout);

        debugPrint('[CoinGecko] GET ${uri.path} -> ${res.statusCode}');
        if (res.statusCode == 200) return res;

        if (res.statusCode == 429) {
          final secs = int.tryParse(res.headers['retry-after'] ?? '') ?? 20;
          _cooldownUntil =
              DateTime.now().add(Duration(seconds: secs.clamp(1, 30)));
          throw const ApiException('Rate limited',
              statusCode: 429, retryable: true);
        }
        throw ApiException(
          'HTTP ${res.statusCode}',
          statusCode: res.statusCode,
          retryable: res.statusCode >= 500,
        );
      } catch (e) {
        debugPrint('[CoinGecko] ${uri.path} failed (attempt $attempt): $e');
        final retryable = e is ApiException
            ? e.retryable
            : (e is TimeoutException || e is http.ClientException);
        if (!retryable || attempt >= _maxAttempts) rethrow;
        // 0.8s, 1.6s … plus jitter.
        await Future<void>.delayed(Duration(
          milliseconds: 800 * (1 << (attempt - 1)) + _rng.nextInt(300),
        ));
      }
    }
  }
}