import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../logic/market_limits.dart';
import '../models/market_tab_model.dart';
import '../providers/market_search_provider.dart';
import '../providers/market_sources_provider.dart';
import 'fade_slide_in_widget.dart';
import 'market_news_tile_widget.dart';
import 'market_states_widget.dart';
import 'market_tab_banner_widget.dart';

/// Latest news, or live search results while a query is active.
class MarketNewsTab extends ConsumerWidget {
  const MarketNewsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(marketNewsProvider);
    final query = ref.watch(marketSearchProvider.select((s) => s.committed));

    Future<void> refresh({bool force = false}) =>
        ref.read(marketRefresherProvider).refresh(MarketTab.news, force: force);

    return async.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: MarketSkeletonRows(count: 6),
      ),
      error: (_, __) => MarketError(
        label: 'news',
        onRetry: () => refresh(force: true),
      ),
      data: (articles) => RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: MarketTabBanner(
                    tab: MarketTab.news, count: articles.length),
              ),
            ),
            if (articles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: MarketEmpty(
                  icon: Iconsax.document_text,
                  title: query.isEmpty ? 'No news yet' : 'No news for “$query”',
                  subtitle: 'Try a different keyword.',
                  suggestions: MarketLimits.searchSuggestions,
                  onSuggestion: (s) =>
                      ref.read(marketSearchProvider.notifier).submit(s),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 640,
                    mainAxisExtent: 104,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => FadeSlideIn(
                      index: i,
                      child: MarketNewsTile(article: articles[i]),
                    ),
                    childCount: articles.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
