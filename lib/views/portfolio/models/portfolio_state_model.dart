import 'crypto_asset_model.dart';

class PortfolioState {
  final double totalBalance;
  final List<CryptoAssetModel> assets;
  final bool hideZeroBalances;

  const PortfolioState({
    required this.totalBalance,
    required this.assets,
    this.hideZeroBalances = false,
  });

  List<CryptoAssetModel> get visibleAssets {
    if (!hideZeroBalances) {
      return assets;
    }

    return assets.where((e) => e.hasBalance).toList();
  }
  

  PortfolioState copyWith({
    double? totalBalance,
    List<CryptoAssetModel>? assets,
    bool? hideZeroBalances,
  }) {
    return PortfolioState(
      totalBalance: totalBalance ?? this.totalBalance,
      assets: assets ?? this.assets,
      hideZeroBalances: hideZeroBalances ?? this.hideZeroBalances,
    );
  }
}