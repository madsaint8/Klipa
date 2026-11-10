import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/market_tab_model.dart';
import '../providers/market_sources_provider.dart';
import '../providers/market_tab_provider.dart';
import '../theme/market_theme.dart';
import 'market_feature_card_widget.dart';
import 'market_section_header_widget.dart';

/// Header + horizontal strip of feature cards for one section.
/// Hides itself quietly if there's nothing to show.
class MarketFeaturedRow extends ConsumerWidget {
  const MarketFeaturedRow({super.key, required this.tab, required this.title});

  final MarketTab tab;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(marketTabItemsProvider(tab));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketSectionHeader(
          title: title,
          tab: tab,
          onSeeAll: () => ref.read(marketTabProvider.notifier).select(tab),
        ),
        SizedBox(
          height: MarketFeatureCard.height + 8,
          child: async.when(
            skipLoadingOnReload: true,
            loading: () => _row(
              List.generate(
                3,
                (_) => Container(
                  width: MarketFeatureCard.width,
                  height: MarketFeatureCard.height,
                  decoration: BoxDecoration(
                    color: MarketColors.border.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => ref
                      .read(marketRefresherProvider)
                      .refresh(tab, force: true),
                  child: Text("Couldn't load $title — tap to retry"),
                ),
              ),
            ),
            data: (items) => _row([
              for (final item in items.take(8)) MarketFeatureCard(item: item),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _row(List<Widget> children) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => children[i],
      );
}
