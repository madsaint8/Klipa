import '../../../data/models/environment/environment.dart';

/// Network configuration for the Ethereum testnet wallet.
class EthNetworkConfig {
  final String name;
  final String rpcHttpUrl;
  final int chainId;
  final String explorerBaseUrl;

  const EthNetworkConfig({
    required this.name,
    required this.rpcHttpUrl,
    required this.chainId,
    required this.explorerBaseUrl,
  });

  static EthNetworkConfig get sepolia => EthNetworkConfig(
        name: 'Ethereum Sepolia',
        rpcHttpUrl: Environment.alchemySepoliaRpcUrl,
        chainId: 11155111,
        explorerBaseUrl: 'https://sepolia.etherscan.io',
      );
}

/// Formats a full 0x address as 0x1234…abcd for compact display.
String shortAddress(String hex, {int head = 6, int tail = 4}) {
  if (hex.length <= head + tail + 2) return hex;
  return '${hex.substring(0, head + 2)}…${hex.substring(hex.length - tail)}';
}