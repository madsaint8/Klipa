import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:paywave/data/models/crypto/chart_period/chart_period.dart';

/// Immutable, validated, pre-computed chart series.
///
/// * `x` is the **epoch time in milliseconds**, so tooltips can show real
///   timestamps and uneven sampling is drawn truthfully.
/// * Bounds and change % are computed once here, never in `build()`.
/// * Construction throws [FormatException] if there is nothing drawable, so
///   the UI shows a proper retry state instead of a blank/flat chart.
@immutable
class ChartData {
  const ChartData._({
    required this.spots,
    required this.minY,
    required this.maxY,
    required this.fetchedAt,
  });

  final List<FlSpot> spots;
  final double minY;
  final double maxY;
  final DateTime fetchedAt;

  double get minX => spots.first.x;
  double get maxX => spots.last.x;

  /// Percentage change between the first and last point.
  double get changePercent {
    final first = spots.first.y;
    if (first == 0) return 0;
    return (spots.last.y - first) / first * 100;
  }

  bool isFresh(Duration ttl) => DateTime.now().difference(fetchedAt) < ttl;

  // ======== Factories ==========================================================

  factory ChartData.fromSpots(
    List<FlSpot> raw, {
    int maxPoints = 300,
    DateTime? fetchedAt,
  }) {
    final clean = raw.where((s) => s.x.isFinite && s.y.isFinite).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    // Drop duplicate timestamps (keep the latest value).
    final unique = <FlSpot>[];
    for (final s in clean) {
      if (unique.isNotEmpty && unique.last.x == s.x) {
        unique[unique.length - 1] = s;
      } else {
        unique.add(s);
      }
    }
    if (unique.length < 2) throw const FormatException('Not enough chart data');

    final spots = _lttb(unique, maxPoints);
    var lo = spots.first.y;
    var hi = lo;
    for (final s in spots) {
      if (s.y < lo) lo = s.y;
      if (s.y > hi) hi = s.y;
    }
    return ChartData._(
      spots: List.unmodifiable(spots),
      minY: lo,
      maxY: hi,
      fetchedAt: fetchedAt ?? DateTime.now(),
    );
  }

  /// Builds a series from the 7-day hourly sparkline (no network needed).
  factory ChartData.fromSparkline(List<double> prices, ChartPeriod period) {
    final now = DateTime.now();
    final n = period.sparklinePoints;
    final slice = prices.length > n ? prices.sublist(prices.length - n) : prices;
    final spots = <FlSpot>[
      for (var i = 0; i < slice.length; i++)
        FlSpot(
          now
              .subtract(Duration(hours: slice.length - 1 - i))
              .millisecondsSinceEpoch
              .toDouble(),
          slice[i],
        ),
    ];
    return ChartData.fromSpots(spots, maxPoints: 120, fetchedAt: now);
  }

  factory ChartData.fromJson(Map<String, dynamic> json) {
    final pts = (json['p'] as List).map((e) {
      final l = e as List;
      return FlSpot((l[0] as num).toDouble(), (l[1] as num).toDouble());
    }).toList();
    return ChartData.fromSpots(
      pts,
      maxPoints: pts.length,
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(json['t'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
        't': fetchedAt.millisecondsSinceEpoch,
        'p': [
          for (final s in spots) [s.x.toInt(), s.y],
        ],
      };

  /// Returns a lighter copy for small widgets (e.g. 60px-tall card charts).
  ChartData downsampled(int maxPoints) => spots.length <= maxPoints
      ? this
      : ChartData.fromSpots(spots, maxPoints: maxPoints, fetchedAt: fetchedAt);

  // ======== Largest-Triangle-Three-Buckets ======================================
  // Industry-standard downsampling that preserves the visual shape (peaks and
  // troughs) of a series, unlike naive stride sampling.

  static List<FlSpot> _lttb(List<FlSpot> d, int threshold) {
    if (threshold >= d.length || threshold < 3) return d;
    final out = <FlSpot>[d.first];
    final every = (d.length - 2) / (threshold - 2);
    var a = 0;
    for (var i = 0; i < threshold - 2; i++) {
      final avgStart = ((i + 1) * every).floor() + 1;
      var avgEnd = ((i + 2) * every).floor() + 1;
      if (avgEnd > d.length) avgEnd = d.length;
      var avgX = 0.0, avgY = 0.0;
      final len = avgEnd - avgStart;
      for (var j = avgStart; j < avgEnd; j++) {
        avgX += d[j].x;
        avgY += d[j].y;
      }
      avgX /= len;
      avgY /= len;

      final rangeStart = (i * every).floor() + 1;
      final rangeEnd = ((i + 1) * every).floor() + 1;
      var maxArea = -1.0;
      var next = rangeStart;
      for (var j = rangeStart; j < rangeEnd; j++) {
        final area = ((d[a].x - avgX) * (d[j].y - d[a].y) -
                (d[a].x - d[j].x) * (avgY - d[a].y))
            .abs();
        if (area > maxArea) {
          maxArea = area;
          next = j;
        }
      }
      out.add(d[next]);
      a = next;
    }
    out.add(d.last);
    return out;
  }
}