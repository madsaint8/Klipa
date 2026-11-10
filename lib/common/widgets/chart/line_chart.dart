import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:paywave/data/models/crypto/chart_data.dart';

/// Shared line chart for [CryptoCard] (compact) and [CoinDetailScreen]
/// (interactive).
///
/// * Takes validated [ChartData]; it can never crash on empty/NaN input.
/// * Y-range is padded so flat series and peaks aren't clipped.
/// * Curves can't overshoot (no fake dips below the real minimum).
/// * Compact mode downsamples and disables animation/touch for cheap rebuilds.
/// * Interactive mode shows a scrubber with price + timestamp tooltip.
class MiniLineChart extends StatelessWidget {
  const MiniLineChart({
    super.key,
    required this.data,
    required this.color,
    this.barWidth = 2,
    this.interactive = false,
    this.maxPoints,
    this.formatPrice,
    this.formatTime,
  });

  final ChartData data;
  final Color color;
  final double barWidth;
  final bool interactive;

  /// Cap on drawn points; use ~60 for small card charts.
  final int? maxPoints;
  final String Function(double price)? formatPrice;
  final String Function(DateTime time)? formatTime;

  @override
  Widget build(BuildContext context) {
    final d = maxPoints == null ? data : data.downsampled(maxPoints!);

    final range = d.maxY - d.minY;
    final pad = range > 0
        ? range * 0.08
        : (d.maxY == 0 ? 1.0 : d.maxY.abs() * 0.01);

    return RepaintBoundary(
      child: LineChart(
        duration: interactive
            ? const Duration(milliseconds: 250)
            : Duration.zero,
        LineChartData(
          minX: d.minX,
          maxX: d.maxX,
          minY: d.minY - pad,
          maxY: d.maxY + pad,
          clipData: const FlClipData.all(),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: d.spots,
              isCurved: true,
              curveSmoothness: 0.2,
              preventCurveOverShooting: true,
              color: color,
              barWidth: barWidth,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.22),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: interactive ? _touchData() : const LineTouchData(enabled: false),
        ),
      ),
    );
  }

  LineTouchData _touchData() => LineTouchData(
        handleBuiltInTouches: true,
        touchSpotThreshold: 32,
        getTouchedSpotIndicator: (bar, indexes) => [
          for (final _ in indexes)
            TouchedSpotIndicatorData(
              FlLine(
                color: color.withValues(alpha: 0.4),
                strokeWidth: 1,
                dashArray: const [4, 4],
              ),
              FlDotData(
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: color,
                ),
              ),
            ),
        ],
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF263238),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (touched) => [
            for (final s in touched)
              LineTooltipItem(
                formatPrice != null ? 'R ${formatPrice!(s.y)}' : s.y.toStringAsFixed(2),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  if (formatTime != null)
                    TextSpan(
                      text:
                          '\n${formatTime!(DateTime.fromMillisecondsSinceEpoch(s.x.toInt()))}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
          ],
        ),
      );
}