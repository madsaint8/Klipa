import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../logic/market_limits.dart';
import '../models/market_tab_model.dart';
import '../providers/market_search_provider.dart';
import '../providers/market_sources_provider.dart';
import '../providers/market_tab_provider.dart';
import '../theme/market_theme.dart';
import 'fade_slide_in_widget.dart';
import 'market_item_tile_widget.dart';
import 'market_news_tile_widget.dart';
import 'market_section_header_widget.dart';
import 'market_states_widget.dart';

/// "All" search view: matches from EVERY section, grouped and ranked, updating
/// as the user types. Each group has "See all" to jump to that section with
/// the same query applied.
class MarketSearchResults extends ConsumerWidget {
  const MarketSearchResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(marketSearchProvider);
    final query = search.committed;
    final news = ref.watch(marketNewsProvider);

    final children = <Widget>[];
    var total = 0;
    var anyPending = false;

    for (final tab in MarketTab.catalogTabs) {
      final async = ref.watch(marketTabItemsProvider(tab));
      final list = async.value;

      if (list == null) {
        if (async.hasError) {
          children.add(_SectionError(
            tab: tab,
            onRetry: () =>
                ref.read(marketRefresherProvider).refresh(tab, force: true),
          ));
        } else {
          anyPending = true;
          children.add(_SectionLoading(tab: tab));
        }
        continue;
      }
      if (list.isEmpty) continue;

      total += list.length;
      children.add(MarketSectionHeader(
        title: tab.label,
        tab: tab,
        count: list.length,
        onSeeAll: list.length > MarketLimits.rowsPerSectionInAll
            ? () => ref.read(marketTabProvider.notifier).select(tab)
            : null,
      ));
      final shown = list.take(MarketLimits.rowsPerSectionInAll).toList();
      for (var i = 0; i < shown.length; i++) {
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: FadeSlideIn(index: i, child: MarketItemTile(item: shown[i])),
        ));
      }
    }

    // News
    final articles = news.value;
    if (articles == null) {
      if (news.hasError) {
        children.add(_SectionError(
          tab: MarketTab.news,
          onRetry: () => ref
              .read(marketRefresherProvider)
              .refresh(MarketTab.news, force: true),
        ));
      } else {
        anyPending = true;
        children.add(const _SectionLoading(tab: MarketTab.news));
      }
    } else if (articles.isNotEmpty) {
      total += articles.length;
      children.add(MarketSectionHeader(
        title: 'News',
        tab: MarketTab.news,
        count: articles.length,
        onSeeAll: articles.length > MarketLimits.rowsPerSectionInAll
            ? () => ref.read(marketTabProvider.notifier).select(MarketTab.news)
            : null,
      ));
      final shown = articles.take(MarketLimits.rowsPerSectionInAll).toList();
      for (var i = 0; i < shown.length; i++) {
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: FadeSlideIn(index: i, child: MarketNewsTile(article: shown[i])),
        ));
      }
    }

    // Nothing matched anywhere (and nothing is still loading).
    if (!anyPending && total == 0 && !search.isSettling) {
      return MarketEmpty(
        icon: Iconsax.search_normal,
        title: 'No results for “$query”',
        subtitle:
            'We searched tokens, RWAs, insurance, equities, services, DeFi and news.',
        suggestions: MarketLimits.searchSuggestions,
        onSuggestion: (s) => ref.read(marketSearchProvider.notifier).submit(s),
      );
    }

    return Column(
      children: [
        // Thin progress bar while the debounce is settling.
        SizedBox(
          height: 2,
          child: search.isSettling
              ? const LinearProgressIndicator(
                  minHeight: 2,
                  color: MarketColors.skyDeep,
                  backgroundColor: Colors.transparent,
                )
              : null,
        ),
        Expanded(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  'Results for “$query”',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: MarketColors.textSub),
                ),
              ),
              ...children,
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading({required this.tab});
  final MarketTab tab;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarketSectionHeader(title: tab.label, tab: tab),
          const MarketSkeletonRows(count: 1),
        ],
      );
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.tab, required this.onRetry});
  final MarketTab tab;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(tab.icon, size: 16, color: MarketColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text("Couldn't search ${tab.label}",
                  style: const TextStyle(color: MarketColors.textSub)),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}
