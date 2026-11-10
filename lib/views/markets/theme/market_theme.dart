import 'package:flutter/material.dart';

import '../models/market_tab_model.dart';

/// Light sky-blue base palette (matches the portfolio + cards features).
class MarketColors {
  MarketColors._();

  static const sky = Color(0xFF4FC3F7);
  static const skyDeep = Color(0xFF0288D1);
  static const skyLight = Color(0xFFE1F5FE);
  static const background = Color(0xFFF4FAFF);
  static const surface = Colors.white;
  static const border = Color(0xFFE3EEF6);
  static const text = Color(0xFF0B2A3D);
  static const textSub = Color(0xFF5F7A8C);
  static const textMuted = Color(0xFF9DB2C0);
  static const positive = Color(0xFF12B76A);
  static const posBg = Color(0xFFE7F8F0);
  static const negative = Color(0xFFF04438);
  static const negBg = Color(0xFFFEECEB);
  static const tag = Color(0xFFEAF4FB);

  static const gradient = LinearGradient(
    colors: [skyDeep, sky],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Each section gets its own vibrant gradient so the marketplace feels alive
/// and users always know where they are.
extension MarketTabStyle on MarketTab {
  List<Color> get _colors => switch (this) {
        MarketTab.discover => const [Color(0xFF0277BD), Color(0xFF4FC3F7)],
        MarketTab.tokens => const [Color(0xFF2563EB), Color(0xFF38BDF8)],
        MarketTab.rwas => const [Color(0xFF059669), Color(0xFF34D399)],
        MarketTab.insurance => const [Color(0xFF7C3AED), Color(0xFFA78BFA)],
        MarketTab.equities => const [Color(0xFFEA580C), Color(0xFFFBBF24)],
        MarketTab.services => const [Color(0xFFDB2777), Color(0xFFF472B6)],
        MarketTab.defi => const [Color(0xFF0284C7), Color(0xFF22D3EE)],
        MarketTab.news => const [Color(0xFF475569), Color(0xFF94A3B8)],
      };

  Color get accent => _colors.first;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _colors,
      );
}

class MarketTheme {
  MarketTheme._();

  static const double maxContentWidth = 1000;
  static const Duration switchDuration = Duration(milliseconds: 280);

  static BoxDecoration card({double radius = 18}) => BoxDecoration(
        color: MarketColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: MarketColors.border),
        boxShadow: [
          BoxShadow(
            color: MarketColors.skyDeep.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );
}
