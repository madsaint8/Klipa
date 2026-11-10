import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/data/models/crypto/chart_period/chart_period.dart';
import 'package:paywave/providers/crypto/crypto_provider.dart';

/// Period selected on the detail screen.
///
/// Starts from whatever the trending section is showing, then is fully
/// independent. autoDispose: leaving the screen resets it.
///
/// There is no CoinDetailNotifier/CoinDetailState any more. The old one
/// registered a new `ref.listen` on every period change (leaking listeners)
/// and only computed chart bounds on *new* events, so already-cached data kept
/// the default 0..1 bounds and the chart rendered off-screen/flat. Bounds are
/// now computed once inside ChartData.
class DetailPeriodNotifier extends Notifier<ChartPeriod> {
  @override
  ChartPeriod build() => ref.read(trendingPeriodProvider);

  void select(ChartPeriod period) {
    if (period != state) state = period;
  }
}

final detailPeriodProvider =
    NotifierProvider.autoDispose<DetailPeriodNotifier, ChartPeriod>(
  DetailPeriodNotifier.new,
);