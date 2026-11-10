class CryptoAssetModel {
  final String name;
  final String symbol;
  final String image;
  final double balance;
  final double fiatValue;
  final String contractAddress;
  final double currentPrice;
  final double priceChange24h;

  const CryptoAssetModel({
    this.currentPrice = 0,
    this.priceChange24h = 0,
    this.contractAddress = '',
    required this.name,
    required this.symbol,
    required this.image,
    required this.balance,
    required this.fiatValue,
  });

  bool get hasBalance => balance > 0;

  CryptoAssetModel copyWith({
    String? name,
    String? symbol,
    String? image,
    double? balance,
    double? fiatValue,
    double? currentPrice,
    double? priceChange24h,
    String? contractAddress,
  }) {
    return CryptoAssetModel(
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      image: image ?? this.image,
      balance: balance ?? this.balance,
      fiatValue: fiatValue ?? this.fiatValue,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      contractAddress: contractAddress ?? this.contractAddress,
    );
  }
}
