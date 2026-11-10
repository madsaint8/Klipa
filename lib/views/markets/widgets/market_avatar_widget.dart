import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/market_item_model.dart';
import '../models/market_tab_model.dart';
import '../theme/market_theme.dart';

/// Logo for any item: network image when available, otherwise a gradient tile
/// with initials (tokens/stocks) or the section icon (everything else).
class MarketAvatar extends StatelessWidget {
  const MarketAvatar({super.key, required this.item, this.size = 46});

  final MarketItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    final fallback = _Fallback(item: item, size: size);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.3),
      child: (url != null && url.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              memCacheWidth: (size * 3).round(), // decode small = less memory
              placeholder: (_, __) => fallback,
              errorWidget: (_, __, ___) => fallback,
            )
          : fallback,
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.item, required this.size});

  final MarketItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final useInitials =
        item.tab == MarketTab.tokens || item.tab == MarketTab.equities;
    final title = item.title.trim();
    final initials = title.isEmpty
        ? '?'
        : title.substring(0, title.length < 2 ? title.length : 2).toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: item.tab.gradient),
      child: Center(
        child: useInitials
            ? Text(initials,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.32))
            : Icon(item.tab.icon, color: Colors.white, size: size * 0.48),
      ),
    );
  }
}
