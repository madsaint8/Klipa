import 'package:flutter/material.dart';

import '../../../../config/theme/colors/app_colors.dart';
import '../../../../config/theme/styles/app_text_styles.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color activeColor;

  const ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color:
                  isActive ? activeColor.withOpacity(0.16) : AppColors.white08,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? activeColor.withOpacity(0.55)
                    : AppColors.white15,
                width: 1,
              ),
            ),
            child: Icon(icon,
                color: isActive ? activeColor : AppColors.white, size: 24),
          ),
          const SizedBox(height: 7),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}