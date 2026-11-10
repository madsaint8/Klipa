import 'package:flutter/material.dart';

import '../logic/market_formatters.dart';
import '../theme/market_theme.dart';

/// Green/red percent pill.
class ChangeBadge extends StatelessWidget {
  const ChangeBadge({super.key, required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final up = percent >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: up ? MarketColors.posBg : MarketColors.negBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        MarketFormatters.percent(percent),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: up ? MarketColors.positive : MarketColors.negative,
        ),
      ),
    );
  }
}
