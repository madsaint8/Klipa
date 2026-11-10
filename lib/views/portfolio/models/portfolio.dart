import 'crypto_asset_model.dart';
import 'wallet_model.dart';
import 'wallet_transaction_model.dart';

class Portfolio {
  final Wallet wallet;
  final List<CryptoAssetModel> assets;
  final List<WalletTransaction> transactions;

  const Portfolio({
    required this.wallet,
    required this.assets,
    required this.transactions,
  });
}