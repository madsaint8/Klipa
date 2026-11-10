import 'package:flutter/foundation.dart';

/// Domain model for a crypto coin.
///
/// Keys mirror the CoinGecko `/coins/markets` response so [fromJson] and
/// [toJson] round-trip perfectly for the disk cache.
///
/// Parsing is deliberately forgiving: CoinGecko returns `null` for many
/// fields (new listings, missing 24h change, ...). A single bad coin must
/// never take the whole trending row down.
@immutable
class CryptoCoin {
  const CryptoCoin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.imageUrl,
    required this.currentPrice,
    required this.priceChangePercent24h,
    this.marketCap,
    this.marketCapRank,
    this.totalVolume,
    this.high24h,
    this.low24h,
    this.ath,
    this.atl,
    this.description,
    this.sparkline,
  });

  final String id;
  final String name;
  final String symbol;
  final String imageUrl;
  final double currentPrice;
  final double priceChangePercent24h;
  final double? marketCap;
  final int? marketCapRank;
  final double? totalVolume;
  final double? high24h;
  final double? low24h;
  final double? ath;
  final double? atl;
  final String? description;

  /// Hourly prices for the last 7 days (≈168 points), oldest first.
  final List<double>? sparkline;

  /// Returns null instead of throwing, so callers can skip malformed items.
  static CryptoCoin? tryParse(Object? raw) {
    if (raw is! Map) return null;
    try {
      return CryptoCoin.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  factory CryptoCoin.fromJson(Map<String, dynamic> json) {
    double? num_(String k) => (json[k] as num?)?.toDouble();

    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const FormatException('Coin is missing an id');
    }

    final sparkRaw = (json['sparkline_in_7d'] as Map?)?['price'];
    final spark = sparkRaw is List
        ? sparkRaw
            .whereType<num>()
            .map((e) => e.toDouble())
            .where((e) => e.isFinite)
            .toList(growable: false)
        : null;

    return CryptoCoin(
      id: id,
      name: (json['name'] as String?) ?? id,
      symbol: (json['symbol'] as String?) ?? '',
      imageUrl: (json['image'] as String?) ?? '',
      currentPrice: num_('current_price') ?? 0,
      priceChangePercent24h: num_('price_change_percentage_24h') ?? 0,
      marketCap: num_('market_cap'),
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt(),
      totalVolume: num_('total_volume'),
      high24h: num_('high_24h'),
      low24h: num_('low_24h'),
      ath: num_('ath'),
      atl: num_('atl'),
      description: json['description'] as String?,
      sparkline: (spark == null || spark.isEmpty) ? null : spark,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbol': symbol,
        'image': imageUrl,
        'current_price': currentPrice,
        'price_change_percentage_24h': priceChangePercent24h,
        if (marketCap != null) 'market_cap': marketCap,
        if (marketCapRank != null) 'market_cap_rank': marketCapRank,
        if (totalVolume != null) 'total_volume': totalVolume,
        if (high24h != null) 'high_24h': high24h,
        if (low24h != null) 'low_24h': low24h,
        if (ath != null) 'ath': ath,
        if (atl != null) 'atl': atl,
        if (description != null) 'description': description,
        if (sparkline != null) 'sparkline_in_7d': {'price': sparkline},
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoCoin &&
          id == other.id &&
          currentPrice == other.currentPrice &&
          priceChangePercent24h == other.priceChangePercent24h &&
          sparkline?.length == other.sparkline?.length &&
          sparkline?.last == other.sparkline?.last;

  @override
  int get hashCode => Object.hash(
        id,
        currentPrice,
        priceChangePercent24h,
        sparkline?.length,
        sparkline?.last,
      );
}