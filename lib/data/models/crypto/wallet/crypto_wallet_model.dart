import '../assets/crypto_asset_model.dart';

class CryptoWalletModel {

  final String address;

  final double totalUsd;

  final List<CryptoAssetModel> assets;

  CryptoWalletModel({
    required this.address,
    required this.totalUsd,
    required this.assets,
  });

}