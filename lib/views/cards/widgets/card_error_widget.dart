import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../../portfolio/app_colors.dart';
import 'glass_action_button_widget.dart';
import 'glass_container_widget.dart';

/// Full-screen failure state with retry. Never shows raw exception text.
class CardError extends StatelessWidget {
  const CardError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassContainer(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.warning_2, size: 44, color: AppColors.negative),
              const SizedBox(height: 14),
              const Text(AppTexts.cardsLoadFailed,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text(AppTexts.cardsLoadFailedSub,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              GlassActionButton(
                icon: Iconsax.refresh,
                label: AppTexts.retry,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}