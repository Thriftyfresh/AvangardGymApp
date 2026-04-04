import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/member_model.dart';

class RevenueBreakdownChart extends StatelessWidget {
  final List<MemberModel> members;
  const RevenueBreakdownChart({super.key, required this.members});

  double _parseAmount(String val) {
    if (val.isEmpty) return 0;
    return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    double totalCash = 0;
    double totalCard = 0;
    double totalBenefit = 0;

    for (final m in members) {
      totalCash += _parseAmount(m.cash);
      totalCard += _parseAmount(m.creditCard);
      totalBenefit += _parseAmount(m.benefit);
    }

    final total = totalCash + totalCard + totalBenefit;

    return Scaffold(
      appBar: AppBar(title: const Text('Revenue Breakdown')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: total == 0
                  ? const Center(child: Text('No revenue data available'))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 50,
                        sections: [
                          if (totalCash > 0)
                            PieChartSectionData(
                              value: totalCash,
                              title: '${(totalCash / total * 100).toStringAsFixed(1)}%',
                              color: Colors.green,
                              radius: 80,
                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          if (totalCard > 0)
                            PieChartSectionData(
                              value: totalCard,
                              title: '${(totalCard / total * 100).toStringAsFixed(1)}%',
                              color: Colors.blue,
                              radius: 80,
                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          if (totalBenefit > 0)
                            PieChartSectionData(
                              value: totalBenefit,
                              title: '${(totalBenefit / total * 100).toStringAsFixed(1)}%',
                              color: Colors.orange,
                              radius: 80,
                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legend(Colors.green, 'Cash'),
                _legend(Colors.blue, 'Card'),
                _legend(Colors.orange, 'Benefit'),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Cash', totalCash),
                    _row('Credit Card', totalCard),
                    _row('Benefit', totalBenefit),
                    const Divider(),
                    _row('Total', total, bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _row(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text('${amount.toStringAsFixed(2)} BD', style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
