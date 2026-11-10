import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Every top-level section of the marketplace.
/// `discover` is the home page (and the "All" view while searching).
enum MarketTab {
  discover('Discover', Iconsax.element_3, 'Everything in one place'),
  tokens('Tokens', Iconsax.coin_1, 'Buy and track crypto tokens'),
  rwas('RWAs', Iconsax.building_4,
      'Tokenized real-world assets: bonds, property, gold & more'),
  insurance('Insurance', Iconsax.shield_tick,
      'Protect your wallet, devices, travel and health'),
  equities('Equities', Iconsax.status_up, 'Tokenized stocks from global markets'),
  services('Services', Iconsax.flash_circle,
      'Airtime, bills, remittance and everyday services'),
  defi('DeFi', Iconsax.layer, 'Top DeFi protocols ranked by TVL'),
  news('News', Iconsax.document_text, 'Latest crypto and market news');

  const MarketTab(this.label, this.icon, this.description);

  final String label;
  final IconData icon;
  final String description;

  /// Tabs whose content is a list of [MarketItem]s (everything but home/news).
  static const List<MarketTab> catalogTabs = [
    tokens,
    rwas,
    insurance,
    equities,
    services,
    defi,
  ];

  /// Tabs where money is at risk -> show the risk note in the buy sheet.
  bool get isInvestment =>
      this == tokens || this == rwas || this == equities;
}
