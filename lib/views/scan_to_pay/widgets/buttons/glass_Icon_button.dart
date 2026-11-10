import 'package:flutter/material.dart';

import '../../../../config/theme/colors/app_colors.dart';

class GlassIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const GlassIconButton({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white08,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white15),
        ),
        child: Icon(icon, color: AppColors.white, size: 20),
      ),
    );
  }
}