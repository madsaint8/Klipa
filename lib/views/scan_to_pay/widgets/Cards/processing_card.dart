import 'package:flutter/material.dart';
import '../../../../config/theme/colors/app_colors.dart';
import '../../../../config/theme/styles/app_text_styles.dart';
import '../../../../data/models/payment_payload.dart';
import '../buttons/glass_card.dart';

class ProcessingCard extends StatelessWidget {
  final PaymentPayload? payload;

  const ProcessingCard({required this.payload});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Processing Payment', style: AppTextStyles.merchantName),
          const SizedBox(height: 8),
          if (payload?.merchantName != null)
            Text(payload!.merchantName!, style: AppTextStyles.subtitle),
          if (payload?.amount != null) ...[
            const SizedBox(height: 20),
            Text(
              payload!.displayAmount,
              style: AppTextStyles.amount.copyWith(color: AppColors.primary),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            'Please do not close the app',
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }
}