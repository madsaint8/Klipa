import 'package:flutter/material.dart';
import '../../../../config/theme/styles/app_text_styles.dart';
import '../../../../data/models/scan_state.dart';

class StatusSubtitle extends StatelessWidget {
  final ScanStatus status;

  const StatusSubtitle({super.key, required this.status});

  String get _text {
    switch (status) {
      case ScanStatus.requestingPermission:
        return 'Requesting camera access...';
      case ScanStatus.permissionDenied:
        return 'Camera access required';
      case ScanStatus.scanning:
        return 'Point camera at a QR code to pay';
      case ScanStatus.detected:
        return 'QR detected — processing...';
      case ScanStatus.processing:
        return 'Verifying your payment...';
      case ScanStatus.success:
        return 'Payment successful!';
      case ScanStatus.error:
        return 'Something went wrong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: Text(
        _text,
        key: ValueKey(status),
        style: AppTextStyles.subtitle,
        textAlign: TextAlign.center,
      ),
    );
  }
}