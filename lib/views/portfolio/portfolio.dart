import 'package:paywave/views/portfolio/models/crypto_asset_model.dart';
import 'models/wallet_model.dart';
import 'models/wallet_transaction_model.dart';

class Portfolio {
  final Wallet wallet;
  final List<CryptoAssetModel> assets;
  final List<WalletTransaction> transactions;

  const Portfolio({
    required this.wallet,
    required this.assets,
    required this.transactions,
  });

  /// Computed total portfolio value (safe + scalable)
  double get totalBalance => wallet.portfolioValue;

  /// Number of assets
  int get assetCount => assets.length;

  /// Check if portfolio is empty
  bool get isEmpty => assets.isEmpty;
}