import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/data/models/crypto/chart_period/chart_period.dart';
import 'package:paywave/providers/crypto/crypto_provider.dart';

import 'crypto_card.dart';

/// Horizontal "trending coins" row.
///
/// Consistency rules:
///  * The row ALWAYS occupies the same height, so loading → data → error
///    never makes the page jump or the section vanish.
///  * Every state (skeleton / error + retry / empty / data) is explicit.
///  * Card width is derived from the available width (phones → tablets).
///  * Period lives in one global provider, not in per-card state.
class TrendingSection extends ConsumerWidget {
  const TrendingSection({super.key, this.title, this.onPeriodChanged});

  final String? title;
  final ValueChanged<ChartPeriod>? onPeriodChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(trendingPeriodProvider);
    final coinsAsync = ref.watch(trendingCoinsProvider);

    ref.listen<ChartPeriod>(
      trendingPeriodProvider,
      (_, next) => onPeriodChanged?.call(next),
    );

    final textScale =
        MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4).toDouble();
    final listHeight = 200.0 * textScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title ?? 'Trending Coins',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Change time period',
                icon: const Icon(Icons.more_horiz),
                onPressed: () => _showFilterSheet(context, ref, period),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Showing price trends for the last ${period.spanLabel}',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: listHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth * 0.72).clamp(220.0, 300.0);
              final extent = cardWidth + 16; // + horizontal card margins

              return coinsAsync.when(
                loading: () => _SkeletonRow(extent: extent),
                error: (_, __) => _MessageState(
                  icon: Icons.wifi_off_rounded,
                  message: 'Could not load coins. Check your connection.',
                  onRetry: () => ref.invalidate(trendingCoinsProvider),
                ),
                data: (coins) => coins.isEmpty
                    ? _MessageState(
                        icon: Icons.search_off_rounded,
                        message: 'No trending coins right now.',
                        onRetry: () => ref.invalidate(trendingCoinsProvider),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemExtent: extent,
                        itemCount: coins.length,
                        itemBuilder: (_, i) => CryptoCard(
                          key: ValueKey(coins[i].id),
                          coin: coins[i],
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref, ChartPeriod current) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _FilterSheet(
        selectedPeriod: current,
        onSelected: (p) => ref.read(trendingPeriodProvider.notifier).select(p),
      ),
    );
  }
}

// ── Filter sheet ──────────────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.selectedPeriod, required this.onSelected});

  final ChartPeriod selectedPeriod;
  final ValueChanged<ChartPeriod> onSelected;

  static IconData _icon(ChartPeriod p) => switch (p) {
        ChartPeriod.oneDay => Icons.today_outlined,
        ChartPeriod.oneWeek => Icons.date_range_outlined,
        ChartPeriod.oneMonth => Icons.calendar_month_outlined,
        ChartPeriod.oneYear => Icons.calendar_today_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Time Period',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            for (final p in ChartPeriod.values)
              ListTile(
                leading: Icon(_icon(p)),
                title: Text(p.longLabel),
                subtitle: Text(
                  'Last ${p.spanLabel} of price data',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: selectedPeriod == p
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  onSelected(p);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── States ────────────────────────────────────────────────────────────────────

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.extent});
  final double extent;

  @override
  Widget build(BuildContext context) => ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemExtent: extent,
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.grey[500]),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
}