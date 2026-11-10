import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/market_tab_model.dart';

/// Currently selected section. Tab bar, pager and "See all" buttons all
/// write here; searching does NOT reset it (the same tab just filters).
class MarketTabNotifier extends Notifier<MarketTab> {
  @override
  MarketTab build() => MarketTab.discover;

  void select(MarketTab tab) {
    if (tab != state) state = tab;
  }
}

final marketTabProvider =
    NotifierProvider.autoDispose<MarketTabNotifier, MarketTab>(
  MarketTabNotifier.new,
);
