import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../models/market_item_model.dart';
import '../theme/market_theme.dart';
import 'market_avatar_widget.dart';
import 'market_item_sheet_widget.dart';

/// Larger card used in the horizontal "featured" rows on Discover.
class MarketFeatureCard extends StatelessWidget {
  const MarketFeatureCard({super.key, required this.item});

  static const double width = 244;
  static const double height = 176;

  final MarketItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: MarketTheme.card(radius: 22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              HapticFeedback.selectionClick();
              showMarketItemSheet(context, item);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MarketAvatar(item: item, size: 42),
                      const Spacer(),
                      if (item.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: item.tab.gradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(item.badge!,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: MarketColors.text)),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: MarketColors.textSub, height: 1.3)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.priceCaption == null
                              ? item.priceLabel
                              : '${item.priceLabel} ${item.priceCaption}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: item.tab.accent),
                        ),
                      ),
                      Icon(Iconsax.arrow_right_3,
                          size: 16, color: item.tab.accent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
