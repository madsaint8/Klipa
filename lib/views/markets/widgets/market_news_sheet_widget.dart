import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/data/models/crypto/news/crypto_news_model.dart';
import 'package:paywave/providers/news/news_provider.dart';

import '../theme/market_theme.dart';
import 'glass_container_widget.dart';
import 'market_news_tile_widget.dart';

Future<void> showMarketNewsSheet(BuildContext context, CryptoNewsArticle a) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MarketNewsSheet(article: a),
  );
}

/// Full article. The list item is shown instantly; the body streams in from
/// the details endpoint, and failure just leaves the summary (no dead end).
class MarketNewsSheet extends ConsumerWidget {
  const MarketNewsSheet({super.key, required this.article});

  final CryptoNewsArticle article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(articleDetailProvider(article.uuid));
    final full = detail.value ?? article;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scroll) => GlassContainer(
        opacity: 0.8,
        blur: 24,
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MarketColors.textMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: LayoutBuilder(
                  builder: (context, c) =>
                      NewsThumb(article: full, size: c.maxWidth),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(full.title,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: MarketColors.text,
                    height: 1.25)),
            const SizedBox(height: 8),
            Text(
              [
                full.sourceName,
                full.timeAgo,
                if (full.author != null) 'by ${full.author}',
              ].join('  ·  '),
              style: const TextStyle(fontSize: 12.5, color: MarketColors.textSub),
            ),
            const SizedBox(height: 16),
            if (full.incipit != null && full.incipit!.isNotEmpty)
              Text(full.incipit!,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: MarketColors.text,
                      height: 1.5)),
            const SizedBox(height: 12),
            detail.when(
              skipLoadingOnReload: true,
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
              ),
              error: (_, __) => const Text(
                "Couldn't load the full article right now.",
                style: TextStyle(color: MarketColors.textSub),
              ),
              data: (a) => Text(
                (a.body ?? '').trim().isEmpty ? '' : a.body!.trim(),
                style: const TextStyle(
                    fontSize: 15, color: MarketColors.text, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
