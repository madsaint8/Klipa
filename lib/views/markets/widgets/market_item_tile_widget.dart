import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/market_item_model.dart';
import '../theme/market_theme.dart';
import 'change_badge_widget.dart';
import 'market_avatar_widget.dart';
import 'market_item_sheet_widget.dart';

/// One row for ANY marketplace item. Works in a list (natural height) and in
/// a responsive grid cell (fills the fixed cell height).
class MarketItemTile extends StatelessWidget {
  const MarketItemTile({super.key, required this.item});

  final MarketItem item;

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
            showMarketItemSheet(context, item);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                MarketAvatar(item: item),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: MarketColors.text)),
                      const SizedBox(height: 2),
                      Text(item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: MarketColors.textSub)),
                      if (item.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _Tags(item.tags.take(2).toList()),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _Trailing(item: item),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags(this.tags);
  final List<String> tags;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 18,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tags.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MarketColors.tag,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(tags[i],
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: MarketColors.textSub)),
          ),
        ),
      );
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.item});
  final MarketItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(item.priceLabel,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: MarketColors.text)),
        const SizedBox(height: 4),
        if (item.changePercent != null)
          ChangeBadge(percent: item.changePercent!)
        else if (item.badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              gradient: item.tab.gradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(item.badge!,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          )
        else if (item.priceCaption != null)
          Text(item.priceCaption!,
              style: const TextStyle(fontSize: 11, color: MarketColors.textMuted)),
      ],
    );
  }
}
