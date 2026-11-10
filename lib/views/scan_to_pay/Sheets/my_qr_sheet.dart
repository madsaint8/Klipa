import 'package:flutter/material.dart';
import '../../../config/theme/colors/app_colors.dart';
import '../../../config/theme/styles/app_text_styles.dart';
import '../widgets/buttons/outlined_action_button.dart';
import 'qr_painter.dart';

class MyQrSheet extends StatelessWidget {
  const MyQrSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.white15,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 22),
          const Text('My QR Code', style: AppTextStyles.screenTitle),
          const SizedBox(height: 6),
          const Text(
            'Share to receive payments',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 28),

          // QR code display
          Container(
            width: 216,
            height: 216,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const CustomPaint(painter: QrPainter()),
          ),
          const SizedBox(height: 22),

          // User identity
          const Text(
            '@johndoe',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text('+1 (555) 000-0000', style: AppTextStyles.subtitle),
          const SizedBox(height: 28),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedActionButton(
                  icon: Icons.download_rounded,
                  label: 'Save',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}