//TODO: move to core themes
import 'package:flutter/material.dart';

/// Sky-blue palette used by the Quick Services UI.
abstract final class SkyTheme {
  static const Color sky50 = Color(0xFFF0F9FF);
  static const Color sky100 = Color(0xFFE0F2FE);
  static const Color sky200 = Color(0xFFBAE6FD);
  static const Color sky300 = Color(0xFF7DD3FC);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky600 = Color(0xFF0284C7);

  /// Deep navy used for text on glass (high contrast on light sky blue).
  static const Color ink = Color(0xFF0C4A6E);

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sky100, sky200, sky300],
  );

  static const LinearGradient iconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sky400, sky600],
  );
}