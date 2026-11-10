
import '../models/network_model.dart';
import '../models/portfolio.dart';
import '../models/wallet_model.dart';
import '../services/blockchain_service.dart';

class PortfolioRepository {
  final BlockchainService blockchain;

  const PortfolioRepository(this.blockchain);

  Future<Portfolio> loadPortfolio(
    String address,
    WalletNetwork network,
  ) async {
    final native = await blockchain.getNativeBalance(
      address,
      network,
    );

    final assets = await blockchain.getTokenBalances(
      address,
      network,
    );

    final wallet = Wallet(
      address: address,
      network: network,
      nativeBalance: native / BigInt.from(10).pow(18),
      portfolioValue: 0,
    );

    return Portfolio(
      wallet: wallet,
      assets: assets,
      transactions: const [],
    );
  }
}