import 'package:flutter/material.dart';

class CornerPainter extends CustomPainter {
  final double progress;
  final Color color;

  CornerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = color.withOpacity(progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.25 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    const arm = 30.0;
    const r = 18.0;
    final w = size.width;
    final h = size.height;

    void draw(Path path) {
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, basePaint);
    }

     // Top-left
    draw(Path()
      ..moveTo(0, arm)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0),
          radius: const Radius.circular(r), clockwise: true)
      ..lineTo(arm, 0));

    // Top-right
    draw(Path()
      ..moveTo(w - arm, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r),
          radius: const Radius.circular(r), clockwise: true)
      ..lineTo(w, arm));

    // Bottom-left
    draw(Path()
      ..moveTo(0, h - arm)
      ..lineTo(0, h - r)
      ..arcToPoint(Offset(r, h),
          radius: const Radius.circular(r), clockwise: false)
      ..lineTo(arm, h));

    // Bottom-right
    draw(Path()
      ..moveTo(w - arm, h)
      ..lineTo(w - r, h)
      ..arcToPoint(Offset(w, h - r),
          radius: const Radius.circular(r), clockwise: false)
      ..lineTo(w, h - arm));
  }


  @override
  bool shouldRepaint(covariant CornerPainter old) =>
      old.progress != progress || old.color != color;
}