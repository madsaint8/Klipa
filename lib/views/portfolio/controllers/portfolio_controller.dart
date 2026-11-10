import '../models/portfolio_state_model.dart';
import '../repositories/portfolio_repository.dart';

class PortfolioController {
  final PortfolioRepository repository;

  PortfolioController(this.repository);

  Future<PortfolioState> loadPortfolio() async {
    final portfolio = await repository.loadPortfolio();

    final total = portfolio.assets.fold<double>(
      0,
      (sum, asset) => sum + asset.fiatValue,
    );

    return PortfolioState(
      totalBalance: total,
      assets: portfolio.assets,
    );
  }
}