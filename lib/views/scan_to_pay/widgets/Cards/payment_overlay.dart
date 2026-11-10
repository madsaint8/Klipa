import 'package:flutter/material.dart';
import '../../../../config/theme/colors/app_colors.dart';
import '../../../../data/models/payment_payload.dart';
import '../../../../data/models/scan_state.dart';
import 'error_card.dart';
import 'processing_card.dart';
import 'success_card.dart';


class PaymentOverlay extends StatelessWidget {
  final ScanStatus status;
  final PaymentPayload? payload;
  final String? errorMessage;
  final Animation<double> successScale;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  const PaymentOverlay({
    super.key,
    required this.status,
    required this.payload,
    required this.errorMessage,
    required this.successScale,
    required this.onDone,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background.withOpacity(0.90),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    switch (status) {
      case ScanStatus.processing:
        return ProcessingCard(payload: payload);
      case ScanStatus.success:
        return SuccessCard(
          payload: payload!,
          scaleAnimation: successScale,
          onDone: onDone,
        );
      case ScanStatus.error:
        return ErrorCard(
          message: errorMessage ?? 'An unexpected error occurred.',
          onRetry: onRetry,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
