import 'package:flutter/material.dart';
import '../../../../config/theme/colors/app_colors.dart';
import 'control_button.dart';
import 'primary_qr_button.dart';

class BottomControls extends StatelessWidget {
  final bool isTorchOn;
  final VoidCallback onTorchToggle;
  final VoidCallback onGallery;
  final VoidCallback onMyQr;

  const BottomControls({
    required this.isTorchOn,
    required this.onTorchToggle,
    required this.onGallery,
    required this.onMyQr,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ControlButton(
          icon: isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          label: isTorchOn ? 'On' : 'Flash',
          isActive: isTorchOn,
          activeColor: AppColors.white,
          onTap: onTorchToggle,
        ),
        const SizedBox(width: 28),
        PrimaryMyQrButton(onTap: onMyQr),
        const SizedBox(width: 28),
        ControlButton(
          icon: Icons.photo_library_rounded,
          label: 'Gallery',
          onTap: onGallery,
        ),
      ],
    );
  }
}