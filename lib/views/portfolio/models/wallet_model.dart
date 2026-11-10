import 'network_model.dart';

class Wallet {
  final String address;
  final WalletNetwork network;
  final double nativeBalance;
  final double portfolioValue;

  const Wallet({
    required this.address,
    required this.network,
    required this.nativeBalance,
    required this.portfolioValue,
  });

  Wallet copyWith({
    String? address,
    WalletNetwork? network,
    double? nativeBalance,
    double? portfolioValue,
  }) {
    return Wallet(
      address: address ?? this.address,
      network: network ?? this.network,
      nativeBalance: nativeBalance ?? this.nativeBalance,
      portfolioValue: portfolioValue ?? this.portfolioValue,
    );
  }
}