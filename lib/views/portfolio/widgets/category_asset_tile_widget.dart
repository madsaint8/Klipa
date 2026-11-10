import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../asset_categories.dart';


class CategoryAssetTile extends StatelessWidget {
  final CategoryAsset asset;
  const CategoryAssetTile({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final up = asset.changePercent >= 0;
    final changeColor = asset.changePercent == 0
        ? AppColors.textMuted
        : (up ? AppColors.positive : AppColors.negative);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppDecor.card(radius: 16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              gradient: AppColors.gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(asset.category.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(asset.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${asset.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(
                '${up ? '+' : ''}${asset.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 12, color: changeColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}