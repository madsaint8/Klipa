import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/market_tab_model.dart';
import '../providers/market_tab_provider.dart';
import '../theme/market_theme.dart';
import 'market_discover_tab_widget.dart';
import 'market_list_tab_widget.dart';
import 'market_news_tab_widget.dart';

/// Swipeable pages kept in sync with the tab bar. Every page keeps its scroll
/// position (AutomaticKeepAlive) and shows the same search filter.
class MarketPager extends ConsumerStatefulWidget {
  const MarketPager({super.key});

  @override
  ConsumerState<MarketPager> createState() => _MarketPagerState();
}

class _MarketPagerState extends ConsumerState<MarketPager> {
  late final PageController _pages =
      PageController(initialPage: ref.read(marketTabProvider).index);

  /// While we animate programmatically, ignore onPageChanged echoes —
  /// otherwise intermediate pages would fight the animation.
  bool _programmatic = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index) async {
    if (!_pages.hasClients) return;
    final current = _pages.page?.round() ?? index;
    if (current == index) return;

    // Far jumps skip intermediate pages (no wasted loading / flicker).
    if ((current - index).abs() > 1 ||
        MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(index);
      return;
    }
    _programmatic = true;
    try {
      await _pages.animateToPage(
        index,
        duration: MarketTheme.switchDuration,
        curve: Curves.easeOutCubic,
      );
    } finally {
      _programmatic = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MarketTab>(marketTabProvider, (_, tab) => _goTo(tab.index));

    return PageView.builder(
      controller: _pages,
      itemCount: MarketTab.values.length,
      onPageChanged: (i) {
        if (_programmatic) return;
        ref.read(marketTabProvider.notifier).select(MarketTab.values[i]);
      },
      itemBuilder: (_, i) => _KeepAlive(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: MarketTheme.maxContentWidth),
            child: _pageFor(MarketTab.values[i]),
          ),
        ),
      ),
    );
  }

  Widget _pageFor(MarketTab tab) => switch (tab) {
        MarketTab.discover => const MarketDiscoverTab(),
        MarketTab.news => const MarketNewsTab(),
        _ => MarketListTab(tab: tab),
      };
}

class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});
  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
