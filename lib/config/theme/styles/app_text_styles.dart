import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
abstract class AppTextStyles {
  static const screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: -0.3,
  );

  static const subtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.6,
  );

  static const amount = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: -1.5,
  );

  static const merchantName = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: -0.2,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.1,
  );
}