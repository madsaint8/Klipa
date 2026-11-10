enum WalletNetwork {
  ethereum,
  polygon,
  base,
  arbitrum,
  optimism,
  bnb,
}

extension WalletNetworkExtension on WalletNetwork {
  String get displayName {
    switch (this) {
      case WalletNetwork.ethereum:
        return 'Ethereum';
      case WalletNetwork.polygon:
        return 'Polygon';
      case WalletNetwork.base:
        return 'Base';
      case WalletNetwork.arbitrum:
        return 'Arbitrum';
      case WalletNetwork.optimism:
        return 'Optimism';
      case WalletNetwork.bnb:
        return 'BNB Chain';
    }
  }

  String get symbol {
    switch (this) {
      case WalletNetwork.ethereum:
        return 'ETH';
      case WalletNetwork.polygon:
        return 'MATIC';
      case WalletNetwork.base:
        return 'ETH';
      case WalletNetwork.arbitrum:
        return 'ETH';
      case WalletNetwork.optimism:
        return 'ETH';
      case WalletNetwork.bnb:
        return 'BNB';
    }
  }
}
