import 'package:flutter/material.dart';
import '../../../../config/theme/colors/app_colors.dart';
import '../../../../config/theme/styles/app_text_styles.dart';
import '../buttons/glass_card.dart';
import '../buttons/primary_button.dart';

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.error.withOpacity(0.35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Scan Failed', style: AppTextStyles.merchantName),
          const SizedBox(height: 10),
          Text(
            message,
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Try Again',
            onTap: onRetry,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}