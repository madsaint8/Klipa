import 'package:flutter/material.dart';

import '../../../../config/theme/colors/app_colors.dart';

class VignettePainter extends CustomPainter {
  final double scannerSize;
  final Size screenSize;

  const VignettePainter({
    required this.scannerSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outer =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: scannerSize,
          height: scannerSize,
        ),
        const Radius.circular(20),
      ));

    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, inner),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withOpacity(0.80),
            AppColors.background.withOpacity(0.65),
            AppColors.background.withOpacity(0.65),
            AppColors.background.withOpacity(0.85),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant VignettePainter old) =>
      old.scannerSize != scannerSize;
}