import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:paywave/common/widgets/crypto/action_button.dart';
import 'package:paywave/common/widgets/chart/line_chart.dart';
import 'package:paywave/common/widgets/crypto/period_selector.dart';
import 'package:paywave/config/theme/colors/app_colors.dart';
import 'package:paywave/data/models/crypto/chart_data.dart';
import 'package:paywave/data/models/crypto/crypto_coin.dart';
import 'package:paywave/providers/crypto/coin_detail_provider.dart';
import 'package:paywave/providers/crypto/crypto_provider.dart';
import 'package:paywave/services/coin_color_extractor.dart';

import '../../../../../core/utils/formatters/crypto/crypto_formatters.dart';

class CoinDetailScreen extends ConsumerWidget {
  const CoinDetailScreen({super.key, required this.coin});

  /// Snapshot used for first paint; the live version is read from the provider.
  final CryptoCoin coin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(coinByIdProvider(coin.id)) ?? coin;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          live.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.heart),
            color: Colors.red,
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          // Keeps content readable on tablets / landscape.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PriceChartCard(coin: live),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ActionButton(label: 'Receive', icon: Iconsax.scan_barcode, onTap: () {}),
                      ActionButton(label: 'Buy', icon: Iconsax.money, onTap: () {}),
                      ActionButton(label: 'Share', icon: Iconsax.share, onTap: () {}),
                      ActionButton(label: 'More', icon: Iconsax.more, onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About ${live.name}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    live.description ??
                        '${live.name} is a digital asset traded on crypto markets.',
                    style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Market Stats'),
                  const SizedBox(height: 12),
                  _StatsCard(coin: live),
                  const SizedBox(height: 24),
                  const _SectionTitle('More Info'),
                  const SizedBox(height: 12),
                  _MoreInfoCard(coin: live),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Price + chart
// ─────────────────────────────────────────────────────────────────────────────

class _PriceChartCard extends ConsumerStatefulWidget {
  const _PriceChartCard({required this.coin});
  final CryptoCoin coin;

  @override
  ConsumerState<_PriceChartCard> createState() => _PriceChartCardState();
}

class _PriceChartCardState extends ConsumerState<_PriceChartCard> {
  /// Last successfully loaded series. While a new period loads we keep showing
  /// it (dimmed) instead of flashing a spinner / empty box.
  ChartData? _lastData;

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;
    final period = ref.watch(detailPeriodProvider);
    final key = (coinId: coin.id, period: period, detail: true);
    final chartAsync = ref.watch(chartProvider(key));
    final fresh = chartAsync.value;
    if (fresh != null) _lastData = fresh;

    // Instant 1D/1W chart from the coin's sparkline (no network), shown while
    // the full-resolution series loads, or if that request fails.
    final preview = ref.watch(sparklinePreviewProvider(key));

    final change =
        (fresh ?? preview)?.changePercent ?? coin.priceChangePercent24h;
    final changeColor = change >= 0 ? Colors.green : Colors.red;
    final chartColor = CoinColorExtractor.brandColor(coin.id);

    Widget chart;
    if (fresh != null) {
      chart = _chart(fresh, chartColor, period);
    } else if (preview != null) {
      chart = Stack(
        children: [
          _chart(preview, chartColor, period),
          if (chartAsync.isLoading)
            const Align(
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      );
    } else if (chartAsync.hasError) {
      chart = _ChartError(onRetry: () => ref.invalidate(chartProvider(key)));
    } else if (_lastData != null) {
      chart = Stack(
        children: [
          Opacity(opacity: 0.4, child: _chart(_lastData!, chartColor, period)),
          const Align(
            alignment: Alignment.bottomCenter,
            child: LinearProgressIndicator(minHeight: 2),
          ),
        ],
      );
    } else {
      chart = const Center(child: CircularProgressIndicator());
    }

    return Card(
      color: AppColors.lightGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ClipOval(
                  child: coin.imageUrl.isEmpty
                      ? const SizedBox(width: 44, height: 44)
                      : CachedNetworkImage(
                          imageUrl: coin.imageUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          memCacheWidth: 132,
                          errorWidget: (_, __, ___) => const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(Icons.currency_bitcoin),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Text(
                  coin.symbol.toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'R ${formatPrice(coin.currentPrice)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${formatSignedPercent(change)} ${change >= 0 ? '▲' : '▼'} ${period.label}',
                        style: TextStyle(
                          color: changeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Height follows width so it looks right on phones and tablets.
            LayoutBuilder(
              builder: (context, c) => SizedBox(
                height: (c.maxWidth / 1.8).clamp(180.0, 340.0),
                child: chart,
              ),
            ),
            const SizedBox(height: 16),
            PeriodSelector(
              selected: period,
              onSelected: ref.read(detailPeriodProvider.notifier).select,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chart(ChartData data, Color color, period) => MiniLineChart(
        data: data,
        color: color,
        barWidth: 2.5,
        interactive: true,
        formatPrice: formatPrice,
        formatTime: (t) => formatChartTime(t, period),
      );
}

class _ChartError extends StatelessWidget {
  const _ChartError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.signal_wifi_off_rounded, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            const Text('Failed to load chart', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats + info
// ─────────────────────────────────────────────────────────────────────────────

String _money(double? v, {bool compact = false}) {
  if (v == null) return 'N/A';
  return 'R ${compact ? formatCompact(v) : formatPrice(v)}';
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.coin});
  final CryptoCoin coin;

  @override
  Widget build(BuildContext context) => _CardShell(children: [
        _InfoRow(label: 'Market Cap', value: _money(coin.marketCap, compact: true)),
        _InfoRow(label: '24h High', value: _money(coin.high24h)),
        _InfoRow(label: '24h Low', value: _money(coin.low24h)),
        _InfoRow(label: 'Volume 24h', value: _money(coin.totalVolume, compact: true)),
      ]);
}

class _MoreInfoCard extends StatelessWidget {
  const _MoreInfoCard({required this.coin});
  final CryptoCoin coin;

  @override
  Widget build(BuildContext context) => _CardShell(children: [
        _InfoRow(label: 'Name', value: coin.name),
        _InfoRow(label: 'Symbol', value: coin.symbol.toUpperCase()),
        _InfoRow(label: 'Rank', value: coin.marketCapRank?.toString() ?? 'N/A'),
        _InfoRow(label: 'All-Time High', value: _money(coin.ath)),
        _InfoRow(label: 'All-Time Low', value: _money(coin.atl)),
      ]);
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(children: children),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
}