import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../../portfolio/app_colors.dart';
import '../models/bank_card_model.dart';
import '../card_theme.dart';
import '../providers/card_ui_provider.dart';
import 'glass_container_widget.dart';

/// Glass segmented control: Physical | Virtual, with a sliding thumb.
class CardKindToggle extends ConsumerWidget {
  const CardKindToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = ref.watch(cardKindProvider);

    return GlassContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 44,
        child: Stack(
          children: [
            AnimatedAlign(
              duration: BankCardTheme.switchDuration,
              curve: Curves.easeOutCubic,
              alignment: kind == CardKind.physical
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.skyDeep.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final k in CardKind.values)
                  Expanded(
                    child: _Tab(
                      kind: k,
                      selected: k == kind,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(cardKindProvider.notifier).select(k);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.kind, required this.selected, required this.onTap});

  final CardKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.skyDeep;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(kind == CardKind.physical ? Iconsax.card : Iconsax.cards,
                  size: 18, color: color),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: BankCardTheme.switchDuration,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
                child: Text(kind == CardKind.physical
                    ? AppTexts.physicalTab
                    : AppTexts.virtualTab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}