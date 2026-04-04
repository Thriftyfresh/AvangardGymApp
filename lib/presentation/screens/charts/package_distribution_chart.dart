import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/member_model.dart';

class PackageDistributionChart extends StatelessWidget {
  final List<MemberModel> members;
  const PackageDistributionChart({super.key, required this.members});

  static const _colors = [
    Colors.deepOrange,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    final packages = <String, int>{};
    for (final m in members) {
      final pkg = m.package.isNotEmpty ? m.package.toLowerCase() : 'unknown';
      packages[pkg] = (packages[pkg] ?? 0) + 1;
    }

    final sorted = packages.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = members.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Package Distribution')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 50,
                  sections: List.generate(sorted.length, (i) {
                    final entry = sorted[i];
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      color: _colors[i % _colors.length],
                      radius: 80,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(sorted.length, (i) {
                final entry = sorted[i];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 14, height: 14, decoration: BoxDecoration(color: _colors[i % _colors.length], shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('${entry.key[0].toUpperCase()}${entry.key.substring(1)} (${entry.value})', style: const TextStyle(fontSize: 13)),
                  ],
                );
              }),
            ),
            const SizedBox(height: 8),
            Text('Total: $total members', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
