import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_colors.dart';
import '../portfolio_features/assets.dart'; // PieChartLegendWidget
import '../providers/chart_provider.dart';

class AssetChart extends ConsumerWidget {
  const AssetChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBar = ref.watch(chartProvider);

    return SizedBox(
      height: 200,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: isBar
            ? const Center(
                key: ValueKey('bar'),
                child: Text(
                  'Bar Chart Content',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              )
            : const PieChartLegendWidget(key: ValueKey('pie')),
      ),
    );
  }
}