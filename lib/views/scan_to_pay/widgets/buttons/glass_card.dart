import 'package:flutter/material.dart';
import '../../../../config/theme/colors/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const GlassCard({super.key, required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor ?? AppColors.white15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
