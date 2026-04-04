import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/member_model.dart';

class StatusPieChart extends StatelessWidget {
  final List<MemberModel> members;
  const StatusPieChart({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final active = members.where((m) => m.status == 'active').length;
    final inactive = members.where((m) => m.status == 'inactive').length;
    final frozen = members.where((m) => m.status == 'frozen').length;
    final total = members.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Membership Status')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      value: active.toDouble(),
                      title: '$active',
                      color: Colors.green,
                      radius: 80,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    PieChartSectionData(
                      value: inactive.toDouble(),
                      title: '$inactive',
                      color: Colors.red,
                      radius: 80,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    PieChartSectionData(
                      value: frozen.toDouble(),
                      title: '$frozen',
                      color: Colors.blueGrey,
                      radius: 80,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legend(Colors.green, 'Active ($active)'),
                _legend(Colors.red, 'Inactive ($inactive)'),
                _legend(Colors.blueGrey, 'Frozen ($frozen)'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total: $total members', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}
