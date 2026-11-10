import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/common/widgets/crypto/trending_section.dart';

import '../models/market_tab_model.dart';
import '../providers/market_search_provider.dart';
import '../providers/market_sources_provider.dart';
import '../providers/market_tab_provider.dart';
import '../theme/market_theme.dart';
import 'fade_slide_in_widget.dart';
import 'market_category_grid_widget.dart';
import 'market_featured_row_widget.dart';
import 'market_hero_widget.dart';
import 'market_news_tile_widget.dart';
import 'market_search_results_widget.dart';
import 'market_section_header_widget.dart';
import 'market_states_widget.dart';

/// Home page. Cross-fades to grouped search results the moment a query is
/// committed, and back when it is cleared.
class MarketDiscoverTab extends ConsumerWidget {
  const MarketDiscoverTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searching =
        ref.watch(marketSearchProvider.select((s) => s.isActive));

    return AnimatedSwitcher(
      duration: MarketTheme.switchDuration,
      switchInCurve: Curves.easeOutCubic,
      child: searching
          ? const MarketSearchResults(key: ValueKey('results'))
          : const _DiscoverHome(key: ValueKey('home')),
    );
  }
}

class _DiscoverHome extends ConsumerWidget {
  const _DiscoverHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: MarketColors.skyDeep,
      onRefresh: () => ref.read(marketRefresherProvider).refresh(MarketTab.discover),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: MarketHero(),
          ),
          SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: MarketCategoryGrid(),
          ),
          SizedBox(height: 22),
          TrendingSection(),
          MarketFeaturedRow(tab: MarketTab.rwas, title: 'Featured assets'),
          MarketFeaturedRow(tab: MarketTab.insurance, title: 'Stay protected'),
          MarketFeaturedRow(tab: MarketTab.services, title: 'Everyday services'),
          _LatestNews(),
        ],
      ),
    );
  }
}

class _LatestNews extends ConsumerWidget {
  const _LatestNews();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(marketNewsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketSectionHeader(
          title: 'Latest news',
          tab: MarketTab.news,
          onSeeAll: () =>
              ref.read(marketTabProvider.notifier).select(MarketTab.news),
        ),
        async.when(
          skipLoadingOnReload: true,
          loading: () => const MarketSkeletonRows(count: 2),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () => ref
                  .read(marketRefresherProvider)
                  .refresh(MarketTab.news, force: true),
              child: const Text("Couldn't load news — tap to retry"),
            ),
          ),
          data: (articles) => Column(
            children: [
              for (var i = 0; i < articles.take(4).length; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: FadeSlideIn(
                    index: i,
                    child: MarketNewsTile(article: articles[i]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
