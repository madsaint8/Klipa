import 'package:flutter/material.dart';
import '../../../../config/theme/colors/app_colors.dart';
import '../../../../config/theme/styles/app_text_styles.dart';
import '../buttons/primary_button.dart';


class PermissionDeniedView extends StatelessWidget {
  final String? message;
  final VoidCallback onOpenSettings;

  const PermissionDeniedView({
    super.key,
    required this.message,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.white08,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.white40,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Camera Access Required',
            style: AppTextStyles.merchantName,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message ??
                'Please grant camera permission to scan QR codes for payments.',
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Open Settings', onTap: onOpenSettings),
        ],
      ),
    );
  }
}