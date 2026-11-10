import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../models/market_tab_model.dart';
import '../theme/market_theme.dart';

/// Section title with optional gradient icon chip, count pill and "See all".
class MarketSectionHeader extends StatelessWidget {
  const MarketSectionHeader({
    super.key,
    required this.title,
    this.tab,
    this.count,
    this.onSeeAll,
  });

  final String title;
  final MarketTab? tab;
  final int? count;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Row(
        children: [
          if (tab != null) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: tab!.gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(tab!.icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: MarketColors.text,
                    ),
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: MarketColors.tag,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$count',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: MarketColors.textSub)),
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  children: [
                    Text('See all',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MarketColors.skyDeep)),
                    SizedBox(width: 2),
                    Icon(Iconsax.arrow_right_3,
                        size: 14, color: MarketColors.skyDeep),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
