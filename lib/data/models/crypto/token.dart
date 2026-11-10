import 'package:flutter/foundation.dart';

@immutable
class Token {
  final String name;
  final String symbol;
  final double price;
  final double changePercent;
  final String iconPath;
  final int rank;
  
  final String network;
  final String marketCap;
  final String totalSupply;
  final String circulatingSupply;
  final String description;
  final String logoUrl;
  final String? website;

  const Token({
    required this.name,
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.iconPath,
    required this.rank,
    required this.network,
    required this.marketCap,
    required this.totalSupply,
    required this.circulatingSupply,
    required this.description,
    required this.logoUrl,
    this.website,
  });
}


