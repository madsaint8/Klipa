import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

enum AssetCategory {
  tokens('Tokens', Iconsax.coin_1),
  nfts('NFTs', Iconsax.gallery),
  rwas('RWAs', Iconsax.building_4),
  cbdcs('CBDCs', Iconsax.bank);

  final String label;
  final IconData icon;
  const AssetCategory(this.label, this.icon);
}

/// Generic holding used by NFTs, RWAs and CBDCs.
/// Tokens keep using your existing CryptoAssetModel.
class CategoryAsset {
  final String id;
  final String name;
  final String subtitle;
  final double value; // fiat value
  final double changePercent;
  final AssetCategory category;

  const CategoryAsset({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.value,
    required this.changePercent,
    required this.category,
  });
}