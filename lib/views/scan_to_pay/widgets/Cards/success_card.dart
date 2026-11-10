import 'package:flutter/material.dart';
import '../../../../config/theme/colors/app_colors.dart';
import '../../../../config/theme/styles/app_text_styles.dart';
import '../../../../data/models/payment_payload.dart';
import '../buttons/glass_card.dart';
import '../buttons/primary_button.dart';

class SuccessCard extends StatelessWidget {
  final PaymentPayload payload;
  final Animation<double> scaleAnimation;
  final VoidCallback onDone;

  const SuccessCard({
    required this.payload,
    required this.scaleAnimation,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.primary.withOpacity(0.35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: scaleAnimation,
            builder: (_, __) => Transform.scale(
              scale: scaleAnimation.value,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text('Payment Sent!', style: AppTextStyles.merchantName),
          const SizedBox(height: 6),
          if (payload.merchantName != null)
            Text('To ${payload.merchantName}', style: AppTextStyles.subtitle),
          const SizedBox(height: 22),
          if (payload.amount != null)
            Text(
              payload.displayAmount,
              style: AppTextStyles.amount.copyWith(color: AppColors.primary),
            ),
          const SizedBox(height: 4),
          Text(payload.formattedTime, style: AppTextStyles.label),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white08,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'TXN: ${payload.transactionId.substring(0, 16).toUpperCase()}',
              style: AppTextStyles.label.copyWith(letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Done', onTap: onDone),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {},
            child: Text(
              'View Receipt',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.white40),
            ),
          ),
        ],
      ),
    );
  }
}