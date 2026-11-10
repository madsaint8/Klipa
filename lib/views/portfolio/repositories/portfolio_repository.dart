import '../models/crypto_asset_model.dart';
import '../models/network_model.dart';
import '../models/portfolio.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';


class PortfolioRepository {
  Future<Portfolio> loadPortfolio() async {
    await Future.delayed(const Duration(milliseconds: 800));

    const wallet = Wallet(
      address: "0x16589e3d48dacb66e3798f885a43eef9c1ba8266",
      network: WalletNetwork.ethereum,
      nativeBalance: 0.00,
      portfolioValue: 0.00,
    );

    const assets = <CryptoAssetModel>[
      CryptoAssetModel(
        name: "Dogecoin",
        symbol: "DOGE",
        image: "assets/logos/crypto/Dogecoin (DOGE).png",
        balance: 0.00,
        fiatValue: 0.00,
        contractAddress: '',
      ),
      CryptoAssetModel(
        name: "SHIBA INU",
        symbol: "SHIB",
        image: "assets/logos/crypto/SHIBA INU (SHIB).png",
        balance: 0,
        fiatValue: 0,
        contractAddress: '',
      ),
    ];

    return const Portfolio(
      wallet: wallet,
      assets: assets,
      transactions: <WalletTransaction>[],
    );
  }
}