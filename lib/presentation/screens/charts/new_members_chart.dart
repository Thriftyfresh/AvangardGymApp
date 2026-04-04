import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/member_model.dart';

class NewMembersChart extends StatelessWidget {
  final List<MemberModel> members;
  const NewMembersChart({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = <String, int>{};

    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      months[key] = 0;
    }

    for (final m in members) {
      final key = '${m.startDate.year}-${m.startDate.month.toString().padLeft(2, '0')}';
      if (months.containsKey(key)) months[key] = months[key]! + 1;
    }

    final keys = months.keys.toList();
    final values = months.values.toList();
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('New Members Per Month')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${_monthLabel(keys[group.x])}\n${rod.toY.toInt()} members',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= keys.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _shortMonth(keys[value.toInt()]),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(keys.length, (i) {
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: values[i].toDouble(), color: Colors.deepOrange, width: 16, borderRadius: BorderRadius.circular(4)),
                    ]);
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _monthLabel(String key) {
    final parts = key.split('-');
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${names[int.parse(parts[1])]} ${parts[0]}';
  }

  String _shortMonth(String key) {
    final parts = key.split('-');
    const names = ['', 'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return names[int.parse(parts[1])];
  }
}
