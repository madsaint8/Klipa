import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../asset_categories.dart';

class AssetCategoryNotifier extends Notifier<AssetCategory> {
  @override
  AssetCategory build() => AssetCategory.tokens;

  void select(AssetCategory c) => state = c;
}

final assetCategoryProvider =
    NotifierProvider<AssetCategoryNotifier, AssetCategory>(
  AssetCategoryNotifier.new,
);

class HideZeroNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final hideZeroProvider =
    NotifierProvider<HideZeroNotifier, bool>(HideZeroNotifier.new);

/// TODO: replace the mock data with your repository / API calls.
final categoryAssetsProvider = Provider<List<CategoryAsset>>((ref) {
  final category = ref.watch(assetCategoryProvider);
  final hideZero = ref.watch(hideZeroProvider);

  const all = <CategoryAsset>[
    CategoryAsset(id: 'n1', name: 'Bored Ape #4821', subtitle: 'Ethereum • ERC-721', value: 18450, changePercent: 3.2, category: AssetCategory.nfts),
    CategoryAsset(id: 'n2', name: 'Azuki #902', subtitle: 'Ethereum • ERC-721', value: 6200, changePercent: -1.4, category: AssetCategory.nfts),
    CategoryAsset(id: 'r1', name: 'Lagos Tower Fund', subtitle: 'Real estate • 120 units', value: 12000, changePercent: 0.8, category: AssetCategory.rwas),
    CategoryAsset(id: 'r2', name: 'US Treasury Bill 6M', subtitle: 'Tokenized bond', value: 5000, changePercent: 0.3, category: AssetCategory.rwas),
    CategoryAsset(id: 'r3', name: 'Tokenized Gold', subtitle: 'Commodity • 2.5 oz', value: 0, changePercent: 0, category: AssetCategory.rwas),
    CategoryAsset(id: 'c1', name: 'eNaira', subtitle: 'Central Bank of Nigeria', value: 850, changePercent: 0, category: AssetCategory.cbdcs),
    CategoryAsset(id: 'c2', name: 'Digital Euro (pilot)', subtitle: 'European Central Bank', value: 0, changePercent: 0, category: AssetCategory.cbdcs),
  ];

  return all
      .where((a) => a.category == category)
      .where((a) => !hideZero || a.value > 0)
      .toList();
});