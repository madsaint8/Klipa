import 'package:flutter/material.dart';

class QrPainter extends CustomPainter {
  final int seed;
  const QrPainter({this.seed = 7654321});

  @override
  void paint(Canvas canvas, Size size) {
    final dark = Paint()
      ..color = const Color(0xFF080810)
      ..style = PaintingStyle.fill;

    const cells = 21;
    final cell = size.width / cells;
    final rng = _Lcg(seed);

    void drawFinder(double ox, double oy) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(ox, oy, cell * 7, cell * 7),
          Radius.circular(cell),
        ),
        dark,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(ox + cell, oy + cell, cell * 5, cell * 5),
          Radius.circular(cell * 0.5),
        ),
        Paint()..color = Colors.white,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(ox + cell * 2, oy + cell * 2, cell * 3, cell * 3),
          Radius.circular(cell * 0.4),
        ),
        dark,
      );
    }

    drawFinder(0, 0);
    drawFinder((cells - 7) * cell, 0);
    drawFinder(0, (cells - 7) * cell);

    for (int r = 0; r < cells; r++) {
      for (int c = 0; c < cells; c++) {
        final inFinder = (r < 9 && c < 9) ||
            (r < 9 && c > cells - 10) ||
            (r > cells - 10 && c < 9);
        if (!inFinder && rng.nextBool()) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                c * cell + 0.6,
                r * cell + 0.6,
                cell - 1.2,
                cell - 1.2,
              ),
              Radius.circular(cell * 0.25),
            ),
            dark,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QrPainter old) => old.seed != seed;
}


/// Simple deterministic LCG so the mock QR pattern is stable across repaints.
class _Lcg {
  int _state;
  _Lcg(int seed) : _state = seed;

  bool nextBool() {
    _state = (_state * 1664525 + 1013904223) & 0xFFFFFFFF;
    return (_state >> 16) & 1 == 1;
  }
}