import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../../portfolio/app_colors.dart';
import '../models/bank_card_model.dart';
import '../providers/card_feedback_provider.dart';
import '../formatters/card_limits.dart';
import '../card_theme.dart';
import '../providers/card_ui_provider.dart';
import '../providers/cards_provider.dart';
import '../repository/create_virtual_card_sheet_widget.dart';

/// Chip strip under the card to switch between cards of the same kind and
/// (for virtual) add a new one. Chips are used instead of a PageView so
/// swiping on the card rotates it without fighting a scroll gesture.
class CardSelector extends ConsumerWidget {
  const CardSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(visibleCardsProvider);
    final selected = ref.watch(selectedCardProvider);
    final kind = ref.watch(cardKindProvider);
    final canAdd = kind == CardKind.virtual;

    if (cards.isEmpty || (cards.length == 1 && !canAdd)) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: cards.length + (canAdd ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == cards.length) {
            return _Chip(
              icon: Iconsax.add,
              label: AppTexts.newCard,
              selected: false,
              onTap: () {
                if (cards.length >= CardLimits.maxVirtualCards) {
                  ref
                      .read(cardFeedbackProvider.notifier)
                      .error(AppTexts.virtualLimitReached);
                  return;
                }
                showCreateVirtualCardSheet(context);
              },
            );
          }
          final card = cards[i];
          return _Chip(
            label: '${card.label} ••${card.last4}',
            selected: card.id == selected?.id,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(selectedCardIdProvider.notifier).select(card.id);
            },
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.skyDeep;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BankCardTheme.switchDuration,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.gradient : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}