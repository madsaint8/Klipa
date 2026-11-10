import 'dart:math';
import '../../../providers/crypto/clients/alchemy_client.dart';
import '../models/crypto_asset_model.dart';
import '../models/network_model.dart';
import '../models/wallet_transaction_model.dart';
import 'blockchain_service.dart';

class AlchemyBlockchainService implements BlockchainService {
  final AlchemyClient client;

  const AlchemyBlockchainService(this.client);

  static const _nativeDecimals = 18;

  double _toDecimal(
    BigInt value,
    int decimals,
  ) {
    return value.toDouble() / pow(10, decimals);
  }

  BigInt _hexToBigInt(String hex) {
    return BigInt.parse(
      hex.replaceFirst('0x', ''),
      radix: 16,
    );
  }

  @override
  Future<BigInt> getNativeBalance(String address, WalletNetwork network) async {
    final hex = await client.getNativeBalance(address);

    return _hexToBigInt(hex);
  }

  @override
  Future<List<CryptoAssetModel>> getTokenBalances(String address, WalletNetwork network) async {
    final json = await client.getTokenBalances(address);

    final balances =
        json["result"]["tokenBalances"] as List<dynamic>;

    final assets = <CryptoAssetModel>[];

    for (final item in balances) {
      final balanceHex = item["tokenBalance"];

      if (balanceHex == null) continue;

      final raw = _hexToBigInt(balanceHex);

      if (raw == BigInt.zero) continue;

      assets.add(
        CryptoAssetModel  (
          name: "",
          symbol: "",
          image: "",
          balance: _toDecimal(raw, _nativeDecimals),
          fiatValue: 0,
          contractAddress: item["contractAddress"],
        ),
      );
    }

    return assets;
  }

  @override
  Future<List<WalletTransaction>> getTransactions(String address, WalletNetwork network) async {
    // TODO
    return [];
  }
}