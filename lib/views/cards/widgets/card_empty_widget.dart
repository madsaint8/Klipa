import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../../portfolio/app_colors.dart';
import '../models/bank_card_model.dart';
import '../card_theme.dart';
import '../repository/create_virtual_card_sheet_widget.dart';
import 'glass_action_button_widget.dart';
import 'glass_container_widget.dart';

/// Shown when the selected kind has no cards.
class CardEmpty extends StatelessWidget {
  const CardEmpty({super.key, required this.kind});

  final CardKind kind;

  @override
  Widget build(BuildContext context) {
    final isVirtual = kind == CardKind.virtual;

    return GlassContainer(
      padding: const EdgeInsets.all(28),
      borderRadius: BorderRadius.circular(BankCardTheme.radius),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.card, size: 48, color: AppColors.skyDeep),
            const SizedBox(height: 14),
            Text(
              isVirtual ? AppTexts.noVirtualCards : AppTexts.noPhysicalCard,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              isVirtual
                  ? AppTexts.noVirtualCardsSub
                  : AppTexts.noPhysicalCardSub,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            if (isVirtual) ...[
              const SizedBox(height: 20),
              GlassActionButton(
                icon: Iconsax.add,
                label: AppTexts.createVirtualTitle,
                onPressed: () => showCreateVirtualCardSheet(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}