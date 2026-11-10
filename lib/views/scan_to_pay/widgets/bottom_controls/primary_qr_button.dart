import 'package:flutter/material.dart';
import '../../../../config/theme/styles/app_text_styles.dart';
import '../../../../config/theme/colors/app_colors.dart';

class PrimaryMyQrButton extends StatelessWidget {
  final VoidCallback onTap;
  const PrimaryMyQrButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2FA4D7), Color(0xFF53CBF3)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.buttonPrimary.withOpacity(0.45),
                  blurRadius: 26,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.qr_code_2_rounded,
                color: AppColors.background, size: 32),
          ),
          const SizedBox(height: 7),
          Text(
            'My QR',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
