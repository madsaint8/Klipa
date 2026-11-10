import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_colors.dart';
import '../providers/chart_provider.dart';

/// Bar / Pie segmented switch.
class AssetToggle extends ConsumerWidget {
  const AssetToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBar = ref.watch(chartProvider);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.skyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            icon: Icons.bar_chart_rounded,
            active: isBar,
            onTap: () => ref.read(chartProvider.notifier).show(bar: true),
          ),
          _Segment(
            icon: Icons.pie_chart_rounded,
            active: !isBar,
            onTap: () => ref.read(chartProvider.notifier).show(bar: false),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _Segment({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.skyDeep.withValues(alpha: .15),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Icon(icon,
            size: 20, color: active ? AppColors.skyDeep : AppColors.textMuted),
      ),
    );
  }
}