import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../config/eth_config.dart';

/// Handles all direct blockchain interaction for a single EVM network
/// (defaults to Ethereum Sepolia) via an Alchemy RPC endpoint.
///
/// SECURITY: this class never persists a private key to disk. It only ever
/// holds it in memory for the lifetime of the app and uses it locally to
/// sign transactions. For production, swap the in-memory key for
/// flutter_secure_storage-backed storage, or better, a hardware/keystore
/// signer.
class WalletService {
  final Web3Client _client;
  final EthNetworkConfig network;

  WalletService({EthNetworkConfig? network})
      : network = network ?? EthNetworkConfig.sepolia,
        _client = Web3Client(network!.rpcHttpUrl, http.Client());

  /// Generates a brand-new random wallet (private key + address).
  EthPrivateKey generateWallet() {
    return EthPrivateKey.createRandom(Random.secure());
  }

  /// Imports a wallet from an existing private key hex string
  /// (with or without the "0x" prefix).
  EthPrivateKey importFromPrivateKey(String privateKeyHex) {
    final cleaned = privateKeyHex.trim().startsWith('0x')
        ? privateKeyHex.trim().substring(2)
        : privateKeyHex.trim();
    if (cleaned.length != 64) {
      throw const FormatException('Private key must be 32 bytes (64 hex chars).');
    }
    return EthPrivateKey.fromHex(cleaned);
  }

  /// Reads the balance (in whole ETH/native units) for a given address.
  Future<double> getBalance(EthereumAddress address) async {
    final balance = await _client.getBalance(address);
    return balance.getValueInUnit(EtherUnit.ether);
  }

  /// Sends [amountEth] of the native token from [sender] to [toAddress].
  /// Returns the transaction hash on success.
  Future<String> sendEth({
    required EthPrivateKey sender,
    required String toAddress,
    required double amountEth,
  }) async {
    final to = EthereumAddress.fromHex(toAddress);

    return _client.sendTransaction(
      sender,
      Transaction(
        to: to,
        value: EtherAmount.fromBigInt(
          EtherUnit.wei,
          BigInt.from(amountEth * 1e18),
        ),
        maxGas: 21000,
      ),
      chainId: network.chainId,
    );
  }

  Future<TransactionReceipt?> getTransactionReceipt(String txHash) {
    return _client.getTransactionReceipt(txHash);
  }

  /// Builds a block-explorer URL for a tx hash on the configured network.
  String explorerTxUrl(String txHash) => '${network.explorerBaseUrl}/tx/$txHash';

  /// Builds a block-explorer URL for an address on the configured network.
  String explorerAddressUrl(String address) =>
      '${network.explorerBaseUrl}/address/$address';

  void dispose() => _client.dispose();
}