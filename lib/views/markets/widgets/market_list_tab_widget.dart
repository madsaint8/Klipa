import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:paywave/common/widgets/crypto/trending_section.dart';

import '../logic/market_limits.dart';
import '../models/market_tab_model.dart';
import '../providers/market_search_provider.dart';
import '../providers/market_sources_provider.dart';
import '../theme/market_theme.dart';
import 'fade_slide_in_widget.dart';
import 'market_item_tile_widget.dart';
import 'market_states_widget.dart';
import 'market_tab_banner_widget.dart';

/// One generic page for Tokens, RWAs, Insurance, Equities, Services and DeFi.
/// Responsive: 1 column on phones, 2+ on tablets/landscape (the grid picks
/// the column count from the available width).
class MarketListTab extends ConsumerWidget {
  const MarketListTab({super.key, required this.tab});

  final MarketTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(marketTabItemsProvider(tab));
    final query = ref.watch(marketSearchProvider.select((s) => s.committed));
    final searching = query.isNotEmpty;

    Future<void> refresh() =>
        ref.read(marketRefresherProvider).refresh(tab, force: false);

    return async.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: MarketSkeletonRows(count: 8),
      ),
      error: (_, __) => MarketError(
        label: tab.label,
        onRetry: () => ref.read(marketRefresherProvider).refresh(tab, force: true),
      ),
      data: (items) => RefreshIndicator(
        color: tab.accent,
        onRefresh: refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: MarketTabBanner(tab: tab, count: items.length),
              ),
            ),
            if (tab == MarketTab.tokens && !searching)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: TrendingSection(title: 'Top Tokens'),
                ),
              ),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: MarketEmpty(
                  icon: Iconsax.search_normal,
                  title: searching
                      ? 'No ${tab.label} match “$query”'
                      : 'Nothing here yet',
                  subtitle: searching
                      ? 'Try another word, or search all sections from Discover.'
                      : 'Pull down to refresh.',
                  suggestions: searching ? MarketLimits.searchSuggestions : const [],
                  onSuggestion: (s) =>
                      ref.read(marketSearchProvider.notifier).submit(s),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 520,
                    mainAxisExtent: 96,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => FadeSlideIn(
                      index: i,
                      child: MarketItemTile(item: items[i]),
                    ),
                    childCount: items.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
