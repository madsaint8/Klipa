import 'package:flutter/material.dart';

/// Single source of truth for the light sky-blue theme.
class AppColors {
  AppColors._();

  static const sky = Color(0xFF4FC3F7);
  static const skyDeep = Color(0xFF0288D1);
  static const skyLight = Color(0xFFE1F5FE);
  static const background = Color(0xFFF4FAFF);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF0B2A3D);
  static const textMuted = Color(0xFF6B8294);
  static const positive = Color(0xFF12B76A);
  static const negative = Color(0xFFF04438);

  static const gradient = LinearGradient(
    colors: [sky, skyDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppDecor {
  AppDecor._();

  static BoxDecoration card({double radius = 20}) => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.skyDeep.withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );
}