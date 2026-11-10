import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: CustomPaint(
            painter: PieChartPainter(),
          ),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final values = [36, 20, 12, 8, 24]; // Percentages
    final colors = [
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.red,
    ];

    double startAngle = -90 * 3.14159 / 180;
    const gapSize = 15 * 3.14159 / 180;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / 100) * 360 * 3.14159 / 180;

      paint.color = colors[i];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - gapSize,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 16, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
