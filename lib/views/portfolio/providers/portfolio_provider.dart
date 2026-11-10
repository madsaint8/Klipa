import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/portfolio.dart';
import '../repositories/portfolio_repository.dart';

final portfolioRepositoryProvider =
    Provider<PortfolioRepository>((ref) {
  return PortfolioRepository();
});

final portfolioProvider =
    AsyncNotifierProvider<PortfolioNotifier, Portfolio>(
  PortfolioNotifier.new,
);

class PortfolioNotifier extends AsyncNotifier<Portfolio> {
  late PortfolioRepository _repo;

  @override
  Future<Portfolio> build() async {
    _repo = ref.read(portfolioRepositoryProvider);
    return _repo.loadPortfolio();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.loadPortfolio(),
    );
  }
}