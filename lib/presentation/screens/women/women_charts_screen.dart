import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/women/women_member_bloc.dart';
import '../../../bloc/member/member_state.dart';
import '../../../data/models/member_model.dart';
import '../charts/status_pie_chart.dart';
import '../charts/new_members_chart.dart';
import '../charts/revenue_breakdown_chart.dart';
import '../charts/monthly_revenue_chart.dart';
import '../charts/package_distribution_chart.dart';

class WomenChartsScreen extends StatefulWidget {
  const WomenChartsScreen({super.key});

  @override
  State<WomenChartsScreen> createState() => _WomenChartsScreenState();
}

class _WomenChartsScreenState extends State<WomenChartsScreen> {
  int? _selectedYear;
  int? _selectedMonth;

  static const _months = [
    'All Months', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  List<int> _getAvailableYears(List<MemberModel> members) {
    final years = members.map((m) => m.startDate.year).toSet().toList()..sort((a, b) => b.compareTo(a));
    return years;
  }

  List<MemberModel> _filterMembers(List<MemberModel> members) {
    var filtered = members;
    if (_selectedYear != null) filtered = filtered.where((m) => m.startDate.year == _selectedYear).toList();
    if (_selectedMonth != null && _selectedMonth! > 0) filtered = filtered.where((m) => m.startDate.month == _selectedMonth).toList();
    return filtered;
  }

  String _getFilterLabel() {
    if (_selectedYear == null) return 'All Time';
    if (_selectedMonth == null || _selectedMonth == 0) return '$_selectedYear';
    return '${_months[_selectedMonth!]} $_selectedYear';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Women\'s Charts'),
        backgroundColor: Colors.pink.shade600,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<WomenMemberBloc, MemberState>(
        builder: (context, state) {
          if (state is! MemberLoaded) return const Center(child: Text('Load members first'));
          final allMembers = state.members;
          final years = _getAvailableYears(allMembers);
          final filtered = _filterMembers(allMembers);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedYear,
                        decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: [const DropdownMenuItem(value: null, child: Text('All Years')), ...years.map((y) => DropdownMenuItem(value: y, child: Text('$y')))],
                        onChanged: (v) => setState(() { _selectedYear = v; if (v == null) _selectedMonth = null; }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedMonth,
                        decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: [const DropdownMenuItem(value: null, child: Text('All Months')), for (int i = 1; i <= 12; i++) DropdownMenuItem(value: i, child: Text(_months[i]))],
                        onChanged: _selectedYear == null ? null : (v) => setState(() => _selectedMonth = v),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text('${_getFilterLabel()} • ${filtered.length} members', style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _chartTile(context, Icons.pie_chart, Colors.pink, 'Membership Status', 'Active vs Inactive vs Frozen', () => _open(context, StatusPieChart(members: filtered))),
                    _chartTile(context, Icons.bar_chart, Colors.pink.shade300, 'New Members Per Month', 'Signups over time', () => _open(context, NewMembersChart(members: filtered))),
                    _chartTile(context, Icons.monetization_on, Colors.purple, 'Revenue Breakdown', 'Cash vs Card vs Benefit', () => _open(context, RevenueBreakdownChart(members: filtered))),
                    _chartTile(context, Icons.show_chart, Colors.pink.shade700, 'Monthly Revenue Trend', 'Income over time', () => _open(context, MonthlyRevenueChart(members: filtered))),
                    _chartTile(context, Icons.donut_large, Colors.teal, 'Package Distribution', 'Gym, Boxing, etc.', () => _open(context, PackageDistributionChart(members: filtered))),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _open(BuildContext context, Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Widget _chartTile(BuildContext context, IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
