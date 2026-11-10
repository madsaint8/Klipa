import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/crypto/crypto_coin.dart';
import '../../../../providers/crypto/crypto_provider.dart';
import 'coin_details/coin_details_screen.dart';

/// Markets list screen — Riverpod-powered, offline-first via
/// [trendingCoinsProvider]. Replaces the old StatefulWidget + http.get.
class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final coinsAsync = ref.watch(trendingCoinsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Crypto Currency',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ========= Search bar =========================================
            TextField(
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Search coins',
              ),
            ),

            const SizedBox(height: 24),

            // ========= List ==============================================
            Expanded(
              child: coinsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorView(
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(trendingCoinsProvider),
                ),
                data: (coins) {
                  final filtered = _query.isEmpty
                      ? coins
                      : coins
                          .where((c) =>
                              c.name.toLowerCase().contains(_query) ||
                              c.symbol.toLowerCase().contains(_query))
                          .toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No coins found'));
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _CoinTile(coin: filtered[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================
//               CoinTile
// ========================================================

class _CoinTile extends StatelessWidget {
  final CryptoCoin coin;
  const _CoinTile({required this.coin});

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChangePercent24h >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final arrow = isPositive ? '▲' : '▼';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CoinDetailScreen(coin: coin),  
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Image.network(
          coin.imageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.currency_bitcoin, color: Colors.orange),
        ),
      ),
      title: Text(
        coin.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        coin.symbol.toUpperCase(),
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'R ${_formatPrice(coin.currentPrice)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${coin.priceChangePercent24h.abs().toStringAsFixed(2)}% $arrow',
            style: TextStyle(color: changeColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(2)}M';
    if (price >= 1000) {
      final parts   = price.toStringAsFixed(2).split('.');
      final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]} ',
      );
      return '$intPart.${parts[1]}';
    }
    return price.toStringAsFixed(2);
  }
}

// ========================================================
//                  _ErrorView
// ========================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Could not load coins',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
}