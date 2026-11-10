import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:paywave/data/models/crypto/chart_data.dart';
import 'package:paywave/data/models/crypto/chart_period/chart_period.dart';
import 'package:paywave/data/models/crypto/crypto_coin.dart';
import 'package:paywave/services/coingecko_service.dart';

class CachedCoins {
  const CachedCoins(this.coins, this.savedAt);
  final List<CryptoCoin> coins;
  final DateTime savedAt;

  bool get isStale =>
      DateTime.now().difference(savedAt) > CryptoRepository.coinsTtl;
}

/// Single place that decides *when the network is hit*.
///
/// Chart lookup order:
///   1. memory cache (fresh)  →  2. disk cache (fresh)  →  3. network
/// If the network fails and *any* cached copy exists (even expired), it is
/// returned instead of an error ("stale-if-error"), so charts keep working
/// offline and under rate limiting.
///
/// Concurrent requests for the same coin/period share one in-flight future,
/// and all network calls pass through a small queue (max 2 concurrent, spaced
/// apart) so a row of cards can never burst the API.
class CryptoRepository {
  CryptoRepository(this._service);

  final CoinGeckoService _service;
  final _queue = _RequestQueue();

  static const coinsTtl = Duration(minutes: 3);
  static const _coinsKey = 'crypto.coins.v3';
  static String _chartKey(String id, ChartPeriod p) =>
      'crypto.chart.v3.$id.${p.name}';

  final Map<String, ChartData> _memory = {};
  final Map<String, Future<ChartData>> _chartInflight = {};
  Future<List<CryptoCoin>>? _coinsInflight;

  // ── Coins ──────────────────────────────────────────────────────────────────

  Future<CachedCoins?> readCachedCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_coinsKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final coins = (map['coins'] as List)
          .map(CryptoCoin.tryParse)
          .whereType<CryptoCoin>()
          .toList();
      return CachedCoins(
        coins,
        DateTime.fromMillisecondsSinceEpoch(map['t'] as int),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<CryptoCoin>> fetchAndCacheCoins() {
    return _coinsInflight ??= () async {
      try {
        final coins = await _queue.run(_service.fetchTrendingCoins, priority: true);
        if (coins.isEmpty) throw const FormatException('No coins returned');
        unawaited(_writeCoins(coins));
        return coins;
      } finally {
        _coinsInflight = null;
      }
    }();
  }

  Future<void> _writeCoins(List<CryptoCoin> coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _coinsKey,
        jsonEncode({
          't': DateTime.now().millisecondsSinceEpoch,
          'coins': coins.map((c) => c.toJson()).toList(),
        }),
      );
    } catch (_) {/* cache is best-effort */}
  }

  // ── Charts ─────────────────────────────────────────────────────────────────

  Future<ChartData> loadChart(
    String coinId,
    ChartPeriod period, {
    bool highPriority = false,
    bool forceRefresh = false,
  }) async {
    final key = _chartKey(coinId, period);
    final ttl = period.cacheTtl;

    final mem = _memory[key];
    if (!forceRefresh && mem != null && mem.isFresh(ttl)) return mem;

    final disk = mem ?? await _readChart(key);
    if (!forceRefresh && disk != null && disk.isFresh(ttl)) {
      _memory[key] = disk;
      return disk;
    }

    return _chartInflight[key] ??= _fetchChart(
      key, coinId, period, disk, highPriority,
    ).whenComplete(() => _chartInflight.remove(key));
  }

  Future<ChartData> _fetchChart(
    String key,
    String coinId,
    ChartPeriod period,
    ChartData? stale,
    bool priority,
  ) async {
    try {
      // Hard ceiling so the UI can never spin forever (queue wait + retries).
      final spots = await _queue
          .run(
            () => _service.fetchChartSpots(coinId, period),
            priority: priority,
          )
          .timeout(const Duration(seconds: 25));
      final data = ChartData.fromSpots(spots);
      _memory[key] = data;
      unawaited(_writeChart(key, data));
      return data;
    } catch (_) {
      if (stale != null) return stale; // stale-if-error
      rethrow;
    }
  }

  Future<ChartData?> _readChart(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;
      return ChartData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeChart(String key, ChartData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data.toJson()));
    } catch (_) {/* cache is best-effort */}
  }
}

/// Minimal async limiter: at most [maxConcurrent] tasks at once, with at least
/// [minGap] between task starts. Priority tasks jump the line.
class _RequestQueue {
  _RequestQueue({
    this.maxConcurrent = 2,
    this.minGap = const Duration(milliseconds: 350),
  });

  final int maxConcurrent;
  final Duration minGap;

  int _active = 0;
  DateTime _lastStart = DateTime.fromMillisecondsSinceEpoch(0);
  final Queue<Completer<void>> _waiters = Queue();

  Future<T> run<T>(Future<T> Function() task, {bool priority = false}) async {
    await _acquire(priority);
    try {
      return await task();
    } finally {
      _release();
    }
  }

  Future<void> _acquire(bool priority) async {
    if (_active < maxConcurrent) {
      _active++;
    } else {
      final c = Completer<void>();
      priority ? _waiters.addFirst(c) : _waiters.addLast(c);
      await c.future; // slot is handed over; _active is unchanged
    }
    final now = DateTime.now();
    final wait = _lastStart.add(minGap).difference(now);
    _lastStart = wait.isNegative ? now : now.add(wait);
    if (!wait.isNegative) await Future<void>.delayed(wait);
  }

  void _release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
    } else {
      _active--;
    }
  }
}