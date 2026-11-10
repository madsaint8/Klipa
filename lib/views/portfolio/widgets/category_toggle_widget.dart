import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/views/portfolio/app_colors.dart';
import '../asset_categories.dart';
import '../providers/asset_category_provider.dart';

/// Horizontal chip selector shown below the chart.
class CategoryToggle extends ConsumerWidget {
  const CategoryToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(assetCategoryProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AssetCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = AssetCategory.values[i];
          final active = c == selected;

          return GestureDetector(
            onTap: () => ref.read(assetCategoryProvider.notifier).select(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: active ? AppColors.gradient : null,
                color: active ? null : AppColors.skyLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(c.icon,
                      size: 18,
                      color: active ? Colors.white : AppColors.skyDeep),
                  const SizedBox(width: 6),
                  Text(
                    c.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.skyDeep,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}