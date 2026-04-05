import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/women/women_member_bloc.dart';
import '../../../bloc/member/member_event.dart';
import '../../../bloc/member/member_state.dart';
import '../../../data/models/member_model.dart';
import '../../widgets/member_card.dart';
import '../member_form_screen.dart';
import '../member_detail_screen.dart';

class WomenMembersScreen extends StatefulWidget {
  final String role;
  const WomenMembersScreen({super.key, this.role = 'admin'});

  @override
  State<WomenMembersScreen> createState() => _WomenMembersScreenState();
}

class _WomenMembersScreenState extends State<WomenMembersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';
  bool get isSuperAdmin => widget.role == 'superadmin';
  final _tabs = ['All', 'Active', 'Inactive', 'Frozen', '🎂'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<WomenMemberBloc>().add(LoadMembers());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<MemberModel> _filtered(List<MemberModel> members, String tab) {
    final searchLower = _search.toLowerCase();
    List<MemberModel> list = tab == 'All' ? members : members.where((m) => m.status == tab.toLowerCase()).toList();
    if (searchLower.isNotEmpty) {
      list = list.where((m) =>
        m.name.toLowerCase().contains(searchLower) ||
        m.phone.contains(_search) ||
        m.cpr.toLowerCase().contains(searchLower)
      ).toList();
    }
    return list;
  }

  Map<int, List<MemberModel>> _groupByYear(List<MemberModel> members) {
    final map = <int, List<MemberModel>>{};
    for (final m in members) {
      map.putIfAbsent(m.startDate.year, () => []);
      map[m.startDate.year]!.add(m);
    }
    return map;
  }

  List<dynamic> _buildFlatList(List<MemberModel> members) {
    if (members.isEmpty) return [];
    final grouped = _groupByYear(members);
    final years = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final flat = <dynamic>[];
    for (final year in years) {
      flat.add(_YearHeader(year, grouped[year]!.length));
      flat.addAll(grouped[year]!);
    }
    return flat;
  }

  int _daysUntilBirthday(String birthday) {
    final now = DateTime.now();
    try {
      final parts = birthday.split(RegExp(r'[/\-]'));
      if (parts.length == 3) {
        final a = int.parse(parts[0]);
        final b = int.parse(parts[1]);
        final c = int.parse(parts[2]);
        DateTime bday;
        if (a > 100) { bday = DateTime(now.year, b, c); }
        else if (c > 100 && a > 12) { bday = DateTime(now.year, b, a); }
        else { bday = DateTime(now.year, a, b); }
        if (bday.isBefore(now.subtract(const Duration(days: 1)))) bday = DateTime(now.year + 1, bday.month, bday.day);
        return bday.difference(now).inDays;
      }
    } catch (_) {}
    return 999;
  }

  List<MemberModel> _upcomingBirthdays(List<MemberModel> members) {
    final results = members.where((m) => m.birthday.isNotEmpty && _daysUntilBirthday(m.birthday) <= 30).toList();
    results.sort((a, b) => _daysUntilBirthday(a.birthday).compareTo(_daysUntilBirthday(b.birthday)));
    return results;
  }

  void _confirmDelete(BuildContext context, MemberModel member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Delete ${member.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<WomenMemberBloc>().add(DeleteMember(member.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildYearGroupedList(List<MemberModel> members) {
    final flat = _buildFlatList(members);
    if (flat.isEmpty) return const Center(child: Text('No members found'));
    return ListView.builder(
      itemCount: flat.length,
      itemBuilder: (context, index) {
        final item = flat[index];
        if (item is _YearHeader) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('${item.year}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink)),
                ),
                const SizedBox(width: 8),
                Text('${item.count} members', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                const Expanded(child: Divider(indent: 12)),
              ],
            ),
          );
        }
        final member = item as MemberModel;
        return MemberCard(
          key: ValueKey(member.id),
          member: member,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member, isWomen: true))),
          onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MemberFormScreen(member: member, isWomen: true))),
          onDelete: isSuperAdmin ? () => _confirmDelete(context, member) : null,
        );
      },
    );
  }

  Widget _buildBirthdayList(List<MemberModel> members) {
    final upcoming = _upcomingBirthdays(members);
    if (upcoming.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.cake_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('No birthdays in the next 30 days', style: TextStyle(color: Colors.grey[500])),
      ]));
    }
    return ListView.builder(
      itemCount: upcoming.length,
      itemBuilder: (context, index) {
        final member = upcoming[index];
        final days = _daysUntilBirthday(member.birthday);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member, isWomen: true))),
            leading: CircleAvatar(backgroundColor: Colors.pink.withOpacity(0.15), child: const Icon(Icons.cake_rounded, color: Colors.pink)),
            title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Birthday: ${member.birthday}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(days == 0 ? 'Today! 🎉' : '$days day${days == 1 ? '' : 's'}',
                style: TextStyle(color: days == 0 ? Colors.pink : Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink, brightness: Theme.of(context).brightness),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Women Members'),
          backgroundColor: Colors.pink.shade600,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name, phone, or CPR...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            Expanded(
              child: BlocBuilder<WomenMemberBloc, MemberState>(
                builder: (context, state) {
                  if (state is MemberLoading) return const Center(child: CircularProgressIndicator(color: Colors.pink));
                  if (state is MemberError) return Center(child: Text(state.message));
                  if (state is! MemberLoaded) return const SizedBox();
                  return TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tab) {
                      if (tab == '🎂') return _buildBirthdayList(state.members);
                      return _buildYearGroupedList(_filtered(state.members, tab));
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.pink,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberFormScreen(isWomen: true))),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _YearHeader {
  final int year;
  final int count;
  _YearHeader(this.year, this.count);
}
