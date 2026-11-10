import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paywave/data/models/crypto/news/crypto_news_model.dart';

import '../theme/market_theme.dart';
import 'market_news_sheet_widget.dart';

class MarketNewsTile extends StatelessWidget {
  const MarketNewsTile({super.key, required this.article});

  final CryptoNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: MarketTheme.card(),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.selectionClick();
            showMarketNewsSheet(context, article);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NewsThumb(article: article, size: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: MarketColors.text,
                              height: 1.3)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(article.sourceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: MarketColors.textSub)),
                          ),
                          const Text('  ·  ',
                              style: TextStyle(
                                  color: MarketColors.textMuted, fontSize: 12)),
                          Text(article.timeAgo,
                              style: const TextStyle(
                                  fontSize: 12, color: MarketColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thumbnail with a badge fallback (also used by the news sheet).
class NewsThumb extends StatelessWidget {
  const NewsThumb({super.key, required this.article, required this.size});

  final CryptoNewsArticle article;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(gradient: MarketColors.gradient),
      alignment: Alignment.center,
      child: Text(
        article.badge,
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
    final url = article.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: (url != null && url.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              memCacheWidth: (size * 3).round(),
              placeholder: (_, __) => fallback,
              errorWidget: (_, __, ___) => fallback,
            )
          : fallback,
    );
  }
}
