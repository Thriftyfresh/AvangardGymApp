import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/member_model.dart';

class MonthlyRevenueChart extends StatelessWidget {
  final List<MemberModel> members;
  const MonthlyRevenueChart({super.key, required this.members});

  double _parseAmount(String val) {
    if (val.isEmpty) return 0;
    return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = <String, double>{};

    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      months[key] = 0;
    }

    for (final m in members) {
      final key = '${m.startDate.year}-${m.startDate.month.toString().padLeft(2, '0')}';
      if (months.containsKey(key)) {
        months[key] = months[key]! + _parseAmount(m.cash) + _parseAmount(m.creditCard) + _parseAmount(m.benefit);
      }
    }

    final keys = months.keys.toList();
    final values = months.values.toList();
    final maxY = values.isEmpty ? 100.0 : (values.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Revenue')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  maxY: maxY == 0 ? 100 : maxY,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          return LineTooltipItem(
                            '${_monthLabel(keys[spot.x.toInt()])}\n${spot.y.toStringAsFixed(2)} BD',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
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
                            child: Text(_shortMonth(keys[value.toInt()]), style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(keys.length, (i) => FlSpot(i.toDouble(), values[i])),
                      isCurved: true,
                      color: Colors.deepOrange,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: Colors.deepOrange.withOpacity(0.15)),
                    ),
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
