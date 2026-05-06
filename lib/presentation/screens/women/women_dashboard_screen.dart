import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/women/women_member_bloc.dart';
import '../../../bloc/member/member_event.dart';
import '../../../bloc/member/member_state.dart';
import '../../../main.dart';
import '../../widgets/stat_card.dart';
import '../login_screen.dart';
import '../admin_screen.dart';
import '../audit_screen.dart';
import '../dashboard_screen.dart';
import 'women_members_screen.dart';
import 'women_import_screen.dart';
import 'women_charts_screen.dart';
import 'women_daily_report_screen.dart';

class WomenDashboardScreen extends StatefulWidget {
  final String role;
  const WomenDashboardScreen({super.key, this.role = 'admin'});

  @override
  State<WomenDashboardScreen> createState() => _WomenDashboardScreenState();
}

class _WomenDashboardScreenState extends State<WomenDashboardScreen> {
  bool get isSuperAdmin => widget.role == 'superadmin';

  @override
  void initState() {
    super.initState();
    context.read<WomenMemberBloc>().add(LoadMembers());
  }

  void _showRemindDialog(String name, String phone, DateTime endDate) {
    final daysLeft = endDate.difference(DateTime.now()).inDays;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remind Member?'),
        content: Text('Send a WhatsApp reminder to $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.message),
            label: const Text('Remind via WhatsApp'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              Navigator.pop(context);
              _openWhatsApp(name, phone, daysLeft);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(String name, String phone, int daysLeft) async {
    String cleanPhone = phone.endsWith('.0') ? phone.substring(0, phone.length - 2) : phone;
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
    cleanPhone = cleanPhone.replaceFirst(RegExp(r'^0+'), '');
    if (!cleanPhone.startsWith('973')) cleanPhone = '973$cleanPhone';
    final message = Uri.encodeComponent(
      'Hi $name,\n\nThis is a friendly reminder from Avangard Gym that your membership will expire in $daysLeft day${daysLeft == 1 ? '' : 's'}.\n\nPlease visit us to renew.\n\nThank you!\nAvangard Gym Team',
    );
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Widget _buildEndDrawer(BuildContext context) {
    final isDark = MyApp.of(context)?.isDark ?? false;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.pink.shade700,
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset('assets/logo.jpg', width: 70, height: 70, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                const Text('Women\'s Section', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.dashboard_rounded, 'Dashboard', () => Navigator.pop(context)),
                _drawerItem(Icons.people_rounded, 'Members', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WomenMembersScreen(role: widget.role)));
                }),
                _drawerItem(Icons.bar_chart_rounded, 'Charts & Stats', isSuperAdmin ? () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WomenChartsScreen()));
                } : null, enabled: isSuperAdmin),
                _drawerItem(Icons.today_rounded, 'Daily Report', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WomenDailyReportScreen()));
                }),
                _drawerItem(Icons.sync_rounded, 'Sync from Sheets', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WomenImportScreen()));
                }),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text('MEN\'S SECTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepOrange[300], letterSpacing: 1)),
                ),
                ListTile(
                  leading: const Icon(Icons.man_rounded, color: Colors.deepOrange),
                  title: const Text('Men\'s Dashboard', style: TextStyle(color: Colors.deepOrange)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen(role: widget.role)));
                  },
                ),
                const Divider(),
                _drawerItem(Icons.admin_panel_settings_rounded, 'Admin Management', isSuperAdmin ? () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
                } : null, enabled: isSuperAdmin),
                _drawerItem(Icons.history_rounded, 'Audit Log', isSuperAdmin ? () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditScreen()));
                } : null, enabled: isSuperAdmin),
                const Divider(),
                ListTile(
                  leading: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                  title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
                  trailing: Switch(
                    value: isDark,
                    activeColor: Colors.pink,
                    onChanged: (_) => MyApp.of(context)?.toggleTheme(),
                  ),
                  onTap: () => MyApp.of(context)?.toggleTheme(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback? onTap, {bool enabled = true}) {
    return ListTile(
      leading: Icon(icon, color: enabled ? null : Colors.grey),
      title: Text(title, style: TextStyle(color: enabled ? null : Colors.grey)),
      subtitle: enabled ? null : const Text('Superadmin only', style: TextStyle(fontSize: 11)),
      enabled: enabled,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Women\'s Section'),
        backgroundColor: Colors.pink.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Notifications checked!')),
              );
            },
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildEndDrawer(context),
      body: BlocBuilder<WomenMemberBloc, MemberState>(
        builder: (context, state) {
          if (state is MemberLoading) return const Center(child: CircularProgressIndicator(color: Colors.pink));
          if (state is MemberError) return Center(child: Text(state.message));

          final loaded = state is MemberLoaded ? state : null;

          return RefreshIndicator(
            color: Colors.pink,
            onRefresh: () async => context.read<WomenMemberBloc>().add(LoadMembers()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome 💖', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  const SizedBox(height: 4),
                  const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: StatCard(label: 'Total', count: loaded?.total ?? 0, color: Colors.pink, icon: Icons.people)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(label: 'Active', count: loaded?.active ?? 0, color: Colors.green, icon: Icons.check_circle)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: StatCard(label: 'Inactive', count: loaded?.inactive ?? 0, color: Colors.red, icon: Icons.cancel)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(label: 'Frozen', count: loaded?.frozen ?? 0, color: Colors.blueGrey, icon: Icons.ac_unit)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('Expiring Soon 🔥', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (loaded == null || loaded.expiringSoon.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline, size: 48, color: Colors.green[300]),
                              const SizedBox(height: 12),
                              const Text('No memberships expiring soon', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: loaded.expiringSoon.length,
                      itemBuilder: (context, index) {
                        final member = loaded.expiringSoon[index];
                        final daysLeft = member.endDate.difference(DateTime.now()).inDays;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            onTap: () => _showRemindDialog(member.name, member.phone, member.endDate),
                            leading: CircleAvatar(
                              backgroundColor: Colors.pink.withOpacity(0.15),
                              child: const Icon(Icons.person, color: Colors.pink),
                            ),
                            title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(member.phone),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: daysLeft <= 3 ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$daysLeft day${daysLeft == 1 ? '' : 's'}',
                                style: TextStyle(color: daysLeft <= 3 ? Colors.red : Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pink,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WomenMembersScreen(role: widget.role))),
        icon: const Icon(Icons.people, color: Colors.white),
        label: const Text('Members', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
