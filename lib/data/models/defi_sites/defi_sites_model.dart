class DefiSite {
  final String id;
  final String name;
  final String? url;
  final String category;
  final String? logo;
  final double tvl;
  final double? change1d;
  final double? change7d;
  final List<String> chains;

  const DefiSite({
    required this.id,
    required this.name,
    this.url,
    required this.category,
    this.logo,
    required this.tvl,
    this.change1d,
    this.change7d,
    required this.chains,
  });

  /// DeFiLlama /protocols response shape
  factory DefiSite.fromDeFiLlama(Map<String, dynamic> json) {
    return DefiSite(
      id: json['slug'] as String? ?? json['name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String?,
      category: json['category'] as String? ?? 'DeFi',
      logo: json['logo'] as String?,
      tvl: (json['tvl'] as num?)?.toDouble() ?? 0,
      change1d: (json['change_1d'] as num?)?.toDouble(),
      change7d: (json['change_7d'] as num?)?.toDouble(),
      chains: List<String>.from(json['chains'] as List? ?? []),
    );
  }

  String get formattedTvl {
    if (tvl >= 1000000000) {
      return '\$${(tvl / 1000000000).toStringAsFixed(2)}B';
    } else if (tvl >= 1000000) {
      return '\$${(tvl / 1000000).toStringAsFixed(1)}M';
    } else if (tvl >= 1000) {
      return '\$${(tvl / 1000).toStringAsFixed(1)}K';
    }
    return '\$${tvl.toStringAsFixed(0)}';
  }
}