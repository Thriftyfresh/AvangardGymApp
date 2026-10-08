import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../bloc/member/member_bloc.dart';
import '../../bloc/member/member_event.dart';
import '../../bloc/women/women_member_bloc.dart';
import '../../data/models/member_model.dart';
import '../../data/models/member_history_model.dart';
import 'member_form_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  final MemberModel member;
  final bool isWomen;
  const MemberDetailScreen({super.key, required this.member, this.isWomen = false});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late MemberModel member;
  List<MemberHistory> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    member = widget.member;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final collection = widget.isWomen ? 'women_members' : 'members';
    final snap = await FirebaseFirestore.instance
        .collection(collection)
        .doc(member.id)
        .collection('history')
        .orderBy('startDate', descending: true)
        .get();
    setState(() {
      _history = snap.docs.map((d) => MemberHistory.fromMap(d.id, d.data())).toList();
      _loadingHistory = false;
    });
  }

  void _toggleFreeze() {
    final newStatus = member.status == 'frozen' ? 'active' : 'frozen';
    final action = newStatus == 'frozen' ? 'Freeze' : 'Unfreeze';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$action Member?'),
        content: Text('Are you sure you want to ${action.toLowerCase()} ${member.name}\'s membership?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'frozen' ? Colors.blueGrey : Colors.green,
            ),
            onPressed: () {
              final updated = member.copyWith(status: newStatus);
              if (widget.isWomen) {
                context.read<WomenMemberBloc>().add(UpdateMember(updated));
              } else {
                context.read<MemberBloc>().add(UpdateMember(updated));
              }
              setState(() => member = updated);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${member.name} has been ${newStatus == 'frozen' ? 'frozen' : 'unfrozen'} ✅')),
              );
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  void _showRemindDialog() {
    final daysLeft = member.endDate.difference(DateTime.now()).inDays;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remind Member?'),
        content: Text('Send a WhatsApp reminder to ${member.name} about their membership${daysLeft > 0 ? ' expiring in $daysLeft day${daysLeft == 1 ? '' : 's'}' : ' that has expired'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.message),
            label: const Text('Remind via WhatsApp'),
            onPressed: () {
              Navigator.pop(context);
              _openWhatsApp(daysLeft);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(int daysLeft) async {
    String cleanPhone = member.phone.endsWith('.0') ? member.phone.substring(0, member.phone.length - 2) : member.phone;
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
    cleanPhone = cleanPhone.replaceFirst(RegExp(r'^0+'), '');
    if (!cleanPhone.startsWith('973')) cleanPhone = '973$cleanPhone';

    final String body;
    if (daysLeft > 0) {
      body = 'Hi ${member.name},\n\n'
          'This is a friendly reminder from Avangard Gym that your membership '
          'will expire in $daysLeft day${daysLeft == 1 ? '' : 's'}.\n\n'
          'Please visit us to renew your membership.\n\n'
          'Thank you!\nAvangard Gym Team';
    } else {
      body = 'Hi ${member.name},\n\n'
          'This is a reminder from Avangard Gym that your membership has expired.\n\n'
          'Please visit us to renew your membership.\n\n'
          'Thank you!\nAvangard Gym Team';
    }

    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(body)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callMember() async {
    String cleanPhone = member.phone.endsWith('.0') ? member.phone.substring(0, member.phone.length - 2) : member.phone;
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':   return Colors.green;
      case 'inactive': return Colors.red;
      case 'frozen':   return Colors.blueGrey;
      default:         return Colors.grey;
    }
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = member.endDate.difference(DateTime.now()).inDays;
    final isFrozen = member.status == 'frozen';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_rounded),
            tooltip: 'Call Member',
            onPressed: _callMember,
          ),
          IconButton(
            icon: const Icon(Icons.message_rounded),
            tooltip: 'Remind via WhatsApp',
            onPressed: _showRemindDialog,
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MemberFormScreen(member: member, isWomen: widget.isWomen)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor(member.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor(member.status).withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.status.toUpperCase(),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _statusColor(member.status))),
                      Text(daysLeft < 0 ? 'Expired ${daysLeft.abs()} days ago' : '$daysLeft days remaining',
                          style: TextStyle(color: daysLeft <= 7 ? Colors.orange : Colors.grey)),
                    ],
                  ),
                  Icon(daysLeft < 0 ? Icons.cancel : Icons.check_circle,
                      color: _statusColor(member.status), size: 40),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Freeze/Unfreeze button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(isFrozen ? Icons.play_arrow_rounded : Icons.ac_unit_rounded,
                    color: isFrozen ? Colors.green : Colors.blueGrey),
                label: Text(isFrozen ? 'Unfreeze Membership' : 'Freeze Membership',
                    style: TextStyle(color: isFrozen ? Colors.green : Colors.blueGrey)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isFrozen ? Colors.green : Colors.blueGrey),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _toggleFreeze,
              ),
            ),
            const SizedBox(height: 12),

            _section('Personal Info', [
              _row('Name',     member.name),
              _row('CPR',      member.cpr),
              _row('Birthday', member.birthday),
              _row('Phone',    member.phone),
            ]),

            _section('Membership', [
              _row('Package',    member.package),
              _row('Membership', member.membership),
              _row('Start Date', member.startDate.toLocal().toString().split(' ')[0]),
              _row('End Date',   member.endDate.toLocal().toString().split(' ')[0]),
              _row('Renew',      member.renew),
            ]),

            _section('Payment', [
              _row('Date Paid',   member.datePaid),
              _row('Month Paid',  member.monthPaid),
              _row('Recept',      member.recept),
              _row('Benefit',     member.benefit),
              _row('Cash',        member.cash),
              _row('Credit Card', member.creditCard),
            ]),

            _section('Other', [
              _row('Referral', member.referral),
            ]),

            // Membership History
            if (_loadingHistory)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
              )
            else if (_history.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history_rounded, size: 20, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          Text('Membership History (${_history.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      ..._history.map((h) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _statusColor(h.status).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _statusColor(h.status).withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${h.startDate.day}/${h.startDate.month}/${h.startDate.year} → ${h.endDate.day}/${h.endDate.month}/${h.endDate.year}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _statusColor(h.status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(h.status.toUpperCase(), style: TextStyle(fontSize: 10, color: _statusColor(h.status), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (h.package.isNotEmpty) Text('Package: ${h.package}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            if (h.membership.isNotEmpty) Text('Membership: ${h.membership}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            if (h.cash.isNotEmpty || h.creditCard.isNotEmpty || h.benefit.isNotEmpty)
                              Text(
                                'Payment: ${[if (h.cash.isNotEmpty) 'Cash: ${h.cash}', if (h.creditCard.isNotEmpty) 'Card: ${h.creditCard}', if (h.benefit.isNotEmpty) 'Benefit: ${h.benefit}'].join(' | ')}',
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                            if (h.recept.isNotEmpty) Text('Recept: ${h.recept}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
