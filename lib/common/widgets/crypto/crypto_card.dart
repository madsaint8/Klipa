import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/common/widgets/chart/line_chart.dart';
import 'package:paywave/data/models/crypto/crypto_coin.dart';
import 'package:paywave/providers/crypto/crypto_provider.dart';
import 'package:paywave/services/coin_color_extractor.dart';
import 'package:paywave/views/markets/market_features/screens/coin_details/coin_details_screen.dart';

import '../../../core/utils/formatters/crypto/crypto_formatters.dart';

/// Fills whatever width its parent gives it (the list uses a fixed item
/// extent), so it adapts to any screen size. The chart takes the remaining
/// height, so larger text scales never overflow.
class CryptoCard extends ConsumerWidget {
  const CryptoCard({super.key, required this.coin});

  final CryptoCoin coin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(trendingPeriodProvider);
    final key = (coinId: coin.id, period: period, detail: false);
    final chartAsync = ref.watch(cardChartProvider(key));
    final chartColor = CoinColorExtractor.brandColor(coin.id);

    // Badge reflects the *selected* period; falls back to 24h while loading.
    final change = chartAsync.value?.changePercent ?? coin.priceChangePercent24h;
    final isPositive = change >= 0;
    final trendColor = isPositive ? Colors.green : Colors.red;

    return Semantics(
      button: true,
      label: '${coin.name}, R ${formatPrice(coin.currentPrice)}, '
          '${formatSignedPercent(change)} over ${period.spanLabel}',
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CoinDetailScreen(coin: coin)),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(url: coin.imageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coin.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          coin.symbol.toUpperCase(),
                          maxLines: 1,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: chartAsync.when(
                  loading: () => const _ChartPlaceholder(loading: true),
                  error: (_, __) => _ChartPlaceholder(
                    onRetry: () => ref.invalidate(chartProvider(key)),
                  ),
                  data: (data) => MiniLineChart(
                    data: data,
                    color: chartColor,
                    maxPoints: 60,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'R ${formatPrice(coin.currentPrice)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trendColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          color: trendColor,
                          size: 13,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${change.abs().toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: trendColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    Widget circle({Widget? child}) => Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
          child: child,
        );

    if (url.isEmpty) {
      return circle(
        child: const Icon(Icons.currency_bitcoin, size: 24, color: Colors.white),
      );
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        memCacheWidth: 120,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, __) => circle(),
        errorWidget: (_, __, ___) => circle(
          child: const Icon(Icons.currency_bitcoin, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({this.loading = false, this.onRetry});
  final bool loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.grey[500], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to retry',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}