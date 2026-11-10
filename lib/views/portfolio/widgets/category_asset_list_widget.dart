import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_colors.dart';
import '../providers/asset_category_provider.dart';
import 'category_asset_tile_widget.dart';

class CategoryAssetList extends ConsumerWidget {
  const CategoryAssetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(categoryAssetsProvider);
    final category = ref.watch(assetCategoryProvider);

    if (assets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(category.icon, size: 40, color: AppColors.sky),
              const SizedBox(height: 8),
              Text('No ${category.label} yet',
                  style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [for (final a in assets) CategoryAssetTile(asset: a)],
    );
  }
}