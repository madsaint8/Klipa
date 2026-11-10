import 'package:paywave/data/models/crypto/crypto_coin.dart';
import 'package:paywave/data/models/defi_sites/defi_sites_model.dart';
import 'package:paywave/data/models/equity/equity_model.dart';

import '../models/market_item_model.dart';
import '../models/market_tab_model.dart';
import 'market_formatters.dart';

/// Converts your existing API models into the uniform [MarketItem].
/// If a model changes, this is the ONLY file to touch.
class MarketAdapters {
  MarketAdapters._();

  /// Mapped from your real CryptoCoin: id, name, symbol, imageUrl,
  /// currentPrice, priceChangePercent24h (+ optional marketCap, rank, volume).
  static MarketItem fromCoin(CryptoCoin c) {
    final symbol = c.symbol.toUpperCase();
    final rank = c.marketCapRank;

    return MarketItem(
      id: 'token:${c.id}',
      tab: MarketTab.tokens,
      title: symbol,
      subtitle: c.name,
      priceLabel: MarketFormatters.price(c.currentPrice),
      changePercent: c.priceChangePercent24h,
      imageUrl: c.imageUrl,
      tags: [
        'Crypto',
        if (rank != null) 'Rank #$rank',
      ],
      description: (c.description != null && c.description!.trim().isNotEmpty)
          ? c.description!.trim()
          : 'Buy ${c.name} instantly. Prices are live and can move fast.',
      presets: const [25, 100, 250, 1000],
      minAmount: 5,
      keywords: [c.id, 'coin', 'crypto', 'token'],
    );
  }

  static MarketItem fromEquity(Equity e) => MarketItem(
        id: 'equity:${e.symbol}',
        tab: MarketTab.equities,
        title: e.symbol,
        subtitle: e.name,
        priceLabel: e.formattedPrice,
        changePercent: e.changePercent,
        imageUrl: e.logoUrl,
        tags: [e.exchange, 'Tokenized stock'],
        description:
            'Tokenized exposure to ${e.name}. Volume today: ${e.formattedVolume}.',
        presets: const [50, 100, 250, 500],
        minAmount: 10,
        keywords: const ['stock', 'share', 'equity'],
      );

  static MarketItem fromSite(DefiSite s) => MarketItem(
        id: 'defi:${s.id}',
        tab: MarketTab.defi,
        title: s.name,
        subtitle: s.category,
        priceLabel: s.formattedTvl,
        priceCaption: 'TVL',
        changePercent: s.change1d,
        imageUrl: s.logo,
        tags: s.chains.take(3).toList(),
        description:
            '${s.name} holds ${s.formattedTvl} total value locked across '
            '${s.chains.length} chain${s.chains.length == 1 ? '' : 's'}.',
        action: MarketAction.explore,
        url: s.url,
        keywords: [...s.chains, 'defi', 'protocol', 'site'],
      );
}