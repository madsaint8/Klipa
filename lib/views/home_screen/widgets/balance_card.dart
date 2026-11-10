import 'package:flutter/material.dart';
import 'package:paywave/config/theme/colors/app_colors.dart';
import '../../../core/utils/constants/uidata.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 56.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isVisible ? "R ${balance.toStringAsFixed(2)}" : secret,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.white.withOpacity(0.8),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "Your balance ($currency)",
            style: const TextStyle(
              color: AppColors.softGrey,  //
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}