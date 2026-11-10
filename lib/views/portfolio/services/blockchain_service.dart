import '../models/crypto_asset_model.dart';
import '../models/network_model.dart';
import '../models/wallet_transaction_model.dart';

abstract class BlockchainService {
  Future<BigInt> getNativeBalance(
    String address,
    WalletNetwork network,
  );

  Future<List<CryptoAssetModel>> getTokenBalances(
    String address,
    WalletNetwork network,
  );

  Future<List<WalletTransaction>> getTransactions(
    String address,
    WalletNetwork network,
  );
}

// TODO: create:

// AlchemyBlockchainService

///InfuraBlockchainService

//QuickNodeBlockchainService
