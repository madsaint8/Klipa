import 'package:flutter/material.dart';
import '../portfolio/app_colors.dart';
import 'models/bank_card_model.dart';

// Re-export so every cards widget gets the shared palette from one import.
// TODO: move app_colors.dart into core/theme and update the two paths here.

class BankCardTheme {
  BankCardTheme._();

  static const double aspectRatio = 1.586; // ISO/IEC 7810 ID-1
  static const double designWidth = 340; // faces are laid out at this width
  static const double radius = 22;
  static const double maxContentWidth = 480;

  static const Duration flipDuration = Duration(milliseconds: 420);
  static const Duration switchDuration = Duration(milliseconds: 320);

  static LinearGradient gradientFor(CardKind kind) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: kind == CardKind.physical
            ? const [Color(0xFF01579B), AppColors.sky]
            : const [Color(0xFF3949AB), Color(0xFF4FC3F7)],
      );
}