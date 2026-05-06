import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/member/member_bloc.dart';
import '../../bloc/member/member_state.dart';
import '../../data/models/member_model.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  DateTime _selectedDate = DateTime.now();

  List<MemberModel> _getMembersForDate(List<MemberModel> members, DateTime date) {
    return members.where((m) {
      if (m.datePaid.isEmpty) return false;
      try {
        final parts = m.datePaid.split('/');
        if (parts.length == 3) {
          final day   = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year  = int.parse(parts[2]);
          return day == date.day && month == date.month && year == date.year;
        }
      } catch (_) {}
      return false;
    }).toList();
  }

  Map<String, List<MemberModel>> _groupByReception(List<MemberModel> members) {
    final map = <String, List<MemberModel>>{};
    for (final m in members) {
      String recept = m.recept.trim();
      if (recept.isEmpty) recept = 'Unknown';
      else recept = recept[0].toUpperCase() + recept.substring(1).toLowerCase();
      map.putIfAbsent(recept, () => []);
      map[recept]!.add(m);
    }
    return map;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _receptColor(String name) {
    final colors = [
      Colors.deepOrange, Colors.blue, Colors.green, Colors.purple,
      Colors.teal, Colors.pink, Colors.amber, Colors.indigo, Colors.red, Colors.cyan,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Report')),
      body: BlocBuilder<MemberBloc, MemberState>(
        builder: (context, state) {
          if (state is MemberLoading) return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          if (state is MemberError) return Center(child: Text(state.message));
          if (state is! MemberLoaded) return const Center(child: Text('Load members from dashboard first'));

          final dayMembers = _getMembersForDate(state.members, _selectedDate);
          final grouped = _groupByReception(dayMembers);
          final sortedReceptionists = grouped.keys.toList()
            ..sort((a, b) => grouped[b]!.length.compareTo(grouped[a]!.length));

          return Column(
            children: [
              // Date picker bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Quick today button
                    OutlinedButton(
                      onPressed: () => setState(() => _selectedDate = DateTime.now()),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Today'),
                    ),
                  ],
                ),
              ),

              // Summary card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${dayMembers.length}',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                            ),
                            const Text('Members Joined', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${grouped.keys.length}',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            const Text('Receptionists', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (dayMembers.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No members joined on ${_formatDate(_selectedDate)}',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: sortedReceptionists.length,
                    itemBuilder: (context, index) {
                      final receptionist = sortedReceptionists[index];
                      final members = grouped[receptionist]!;
                      final color = _receptColor(receptionist);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Text(
                              receptionist[0].toUpperCase(),
                              style: TextStyle(color: color, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            receptionist,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text('${members.length} member${members.length == 1 ? '' : 's'}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${members.length}',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          children: members.map((m) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                              child: Text(
                                m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            title: Text(m.name, style: const TextStyle(fontSize: 14)),
                            subtitle: Text('${m.package} • ${m.membership}', style: const TextStyle(fontSize: 12)),
                            trailing: Text(
                              m.cash.isNotEmpty ? 'Cash: ${m.cash}' :
                              m.creditCard.isNotEmpty ? 'Card: ${m.creditCard}' :
                              m.benefit.isNotEmpty ? 'Benefit: ${m.benefit}' : '',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          )).toList(),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
