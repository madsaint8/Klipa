import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../providers/news/news_provider.dart';
import '../../providers/sites/sites_provider.dart';
import '../../providers/equities/equities_provider.dart';

// ─── Tab enum ─────────────────────────────────────────────────────────────────
enum MarketTab { stream, tokens, equities, sites, collections }

extension MarketTabLabel on MarketTab {
  String get label {
    switch (this) {
      case MarketTab.stream:      return 'Stream';
      case MarketTab.tokens:      return 'Tokens';
      case MarketTab.equities:    return 'Equities';
      case MarketTab.sites:       return 'Sites';
      case MarketTab.collections: return 'Collections';
    }
  }
}

// ─── UI state ─────────────────────────────────────────────────────────────────
class MarketsState {
  final MarketTab selectedTab;
  final String searchQuery;

  const MarketsState({
    this.selectedTab = MarketTab.stream,
    this.searchQuery = '',
  });

  MarketsState copyWith({MarketTab? selectedTab, String? searchQuery}) =>
      MarketsState(
        selectedTab: selectedTab ?? this.selectedTab,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class MarketsNotifier extends StateNotifier<MarketsState> {
  final Ref _ref;
  MarketsNotifier(this._ref) : super(const MarketsState());

  void selectTab(MarketTab tab) {
    state = state.copyWith(selectedTab: tab, searchQuery: '');
    _pushQuery('');
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _pushQuery(query);
  }

  void clearSearch() => updateSearch('');

  /// Broadcasts the search query to every data provider so they
  /// all filter/re-fetch reactively without extra wiring in widgets.
  void _pushQuery(String query) {
    // News (client-side text filter)
    _ref.read(newsSearchQueryProvider.notifier).state = query;

    // Sites (client-side filter)
    _ref.read(sitesSearchQueryProvider.notifier).state = query;

    // Equities (client-side filter)
    _ref.read(equitiesSearchQueryProvider.notifier).state = query;

    // Tokens — coin list widgets watch this to filter CoinGecko results
    _ref.read(tokenSearchQueryProvider.notifier).state = query;
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final marketsProvider =
    StateNotifierProvider<MarketsNotifier, MarketsState>((ref) {
  return MarketsNotifier(ref);
});