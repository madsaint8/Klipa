import 'package:flutter/material.dart';
import 'package:paywave/config/theme/colors/app_colors.dart';

class ScanBeam extends StatelessWidget {
  const ScanBeam();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2.5,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.transparent,
            Color.fromARGB(255, 79, 184, 245), // glow
            Color.fromARGB(255, 47, 106, 246), // main brand
            Color.fromARGB(255, 62, 116, 181),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.55),
            blurRadius: 14,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }
}
