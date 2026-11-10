import 'package:flutter/material.dart';
import 'package:paywave/config/theme/colors/app_colors.dart';
import 'package:paywave/data/models/crypto/chart_period/chart_period.dart';

/// Stateless, responsive period selector driven entirely by the parent.
/// Segments share the available width equally (no fixed 45px buttons) and
/// have a 40px touch target.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ChartPeriod selected;
  final ValueChanged<ChartPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.softGrey,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (final p in ChartPeriod.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: p == selected,
                label: p.longLabel,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p == selected
                          ? AppColors.buttonPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            p == selected ? FontWeight.bold : FontWeight.w500,
                        color: p == selected
                            ? Colors.white
                            : AppColors.darkerGrey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}