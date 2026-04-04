import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/member/member_bloc.dart';
import '../../bloc/member/member_state.dart';
import '../../data/models/member_model.dart';
import 'charts/status_pie_chart.dart';
import 'charts/new_members_chart.dart';
import 'charts/revenue_breakdown_chart.dart';
import 'charts/monthly_revenue_chart.dart';
import 'charts/package_distribution_chart.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
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
    if (_selectedYear != null) {
      filtered = filtered.where((m) => m.startDate.year == _selectedYear).toList();
    }
    if (_selectedMonth != null && _selectedMonth! > 0) {
      filtered = filtered.where((m) => m.startDate.month == _selectedMonth).toList();
    }
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
      appBar: AppBar(title: const Text('Charts & Stats')),
      body: BlocBuilder<MemberBloc, MemberState>(
        builder: (context, state) {
          if (state is! MemberLoaded) {
            return const Center(child: Text('Load members first from dashboard'));
          }
          final allMembers = state.members;
          final years = _getAvailableYears(allMembers);
          final filtered = _filterMembers(allMembers);

          return Column(
            children: [
              // Filter bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedYear,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Years')),
                          ...years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))),
                        ],
                        onChanged: (v) => setState(() {
                          _selectedYear = v;
                          if (v == null) _selectedMonth = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Months')),
                          for (int i = 1; i <= 12; i++)
                            DropdownMenuItem(value: i, child: Text(_months[i])),
                        ],
                        onChanged: _selectedYear == null ? null : (v) => setState(() => _selectedMonth = v),
                      ),
                    ),
                  ],
                ),
              ),
              // Filter label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_getFilterLabel()} • ${filtered.length} members',
                        style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Chart list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _chartTile(
                      context,
                      icon: Icons.pie_chart,
                      color: Colors.green,
                      title: 'Membership Status',
                      subtitle: 'Active vs Inactive vs Frozen',
                      onTap: () => _open(context, StatusPieChart(members: filtered)),
                    ),
                    _chartTile(
                      context,
                      icon: Icons.bar_chart,
                      color: Colors.deepOrange,
                      title: 'New Members Per Month',
                      subtitle: 'Signups over time',
                      onTap: () => _open(context, NewMembersChart(members: filtered)),
                    ),
                    _chartTile(
                      context,
                      icon: Icons.monetization_on,
                      color: Colors.blue,
                      title: 'Revenue Breakdown',
                      subtitle: 'Cash vs Credit Card vs Benefit',
                      onTap: () => _open(context, RevenueBreakdownChart(members: filtered)),
                    ),
                    _chartTile(
                      context,
                      icon: Icons.show_chart,
                      color: Colors.purple,
                      title: 'Monthly Revenue Trend',
                      subtitle: 'Income over time',
                      onTap: () => _open(context, MonthlyRevenueChart(members: filtered)),
                    ),
                    _chartTile(
                      context,
                      icon: Icons.donut_large,
                      color: Colors.teal,
                      title: 'Package Distribution',
                      subtitle: 'Gym, Boxing, Crossfit, etc.',
                      onTap: () => _open(context, PackageDistributionChart(members: filtered)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _chartTile(BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
