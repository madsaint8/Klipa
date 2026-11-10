import 'package:flutter/foundation.dart';

import 'market_tab_model.dart';

/// What the primary button does for an item.
enum MarketAction {
  buy('Buy'),
  getCover('Get cover'),
  useService('Get started'),
  explore('Explore');

  const MarketAction(this.label);
  final String label;

  /// false = informational only (no payment).
  bool get isTransaction => this != explore;
}

/// A selectable plan (insurance tiers, service bundles...).
@immutable
class MarketPlan {
  const MarketPlan({
    required this.id,
    required this.label,
    required this.caption,
    required this.amount,
  });

  final String id;
  final String label;
  final String caption;
  final double amount;
}

/// One uniform shape for EVERYTHING sold or listed in the marketplace.
///
/// Tokens, equities, RWAs, insurance, services and DeFi sites are all mapped
/// into this model (see logic/market_adapters.dart). That is what lets one
/// search, one tile, and one buy sheet work across every section.
class MarketItem {
  MarketItem({
    required this.id,
    required this.tab,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    this.priceCaption,
    this.changePercent,
    this.badge,
    this.imageUrl,
    this.tags = const [],
    this.description = '',
    this.action = MarketAction.buy,
    this.minAmount = 1,
    this.presets = const [],
    this.plans = const [],
    this.url,
    List<String> keywords = const [],
  }) : searchText = [
          title,
          subtitle,
          description,
          badge ?? '',
          ...tags,
          ...keywords,
        ].join(' ').toLowerCase();

  final String id;
  final MarketTab tab;
  final String title;
  final String subtitle;
  final String priceLabel;
  final String? priceCaption; // e.g. "TVL", "from"
  final double? changePercent;
  final String? badge; // e.g. "5.1% APY"
  final String? imageUrl;
  final List<String> tags;
  final String description;
  final MarketAction action;
  final double minAmount;
  final List<double> presets;
  final List<MarketPlan> plans;
  final String? url;

  /// Pre-lowercased haystack so searching stays fast while typing.
  final String searchText;
}

@immutable
class PurchaseRequest {
  const PurchaseRequest({
    required this.item,
    required this.amount,
    this.planId,
  });

  final MarketItem item;
  final double amount;
  final String? planId;
}
