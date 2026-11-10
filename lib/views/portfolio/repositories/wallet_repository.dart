
import '../models/network_model.dart';
import '../services/blockchain_service.dart';

class WalletRepository {
  final BlockchainService blockchain;

  const WalletRepository(this.blockchain);

  Future<BigInt> getNativeBalance(
    String address,
    WalletNetwork network,
  ) {
    return blockchain.getNativeBalance(address, network);
  }
}