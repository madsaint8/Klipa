import 'package:flutter/material.dart';
import '../../../common/widgets/crypto/piechart.dart';
class PieChartLegendWidget extends StatelessWidget {
  const PieChartLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            flex: 1,
            child: PieChartWidget(),
          ),
          // Legend
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegendRow(
                  color: Colors.purple,
                  label: 'DOGE',
                  percentage: '36.00%',
                ),
                SizedBox(height: 8),
                LegendRow(
                  color: Colors.red,
                  label: 'SHIBA',
                  percentage: '24.00%',
                ),
                SizedBox(height: 8),
                LegendRow(
                  color: Colors.green,
                  label: 'TRX',
                  percentage: '20.00%',
                ),
                SizedBox(height: 8),
                LegendRow(
                  color: Colors.orange,
                  label: 'XRP',
                  percentage: '12.00%',
                ),
                SizedBox(height: 8),
                LegendRow(
                  color: Colors.blue,
                  label: 'AZN',
                  percentage: '8.00%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;

  const LegendRow({
    super.key,
    required this.color,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        Text(
          percentage,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
