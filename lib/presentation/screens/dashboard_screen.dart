import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/member/member_bloc.dart';
import '../../bloc/member/member_event.dart';
import '../../bloc/member/member_state.dart';
import '../../core/notification_service.dart';
import '../../main.dart';
import '../widgets/stat_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'members_screen.dart';
import 'import_screen.dart';
import 'admin_screen.dart';
import 'charts_screen.dart';
import 'login_screen.dart';
import 'audit_screen.dart';
import 'women/women_dashboard_screen.dart';
import 'daily_report_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String role;
  const DashboardScreen({super.key, this.role = 'admin'});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool get isSuperAdmin => widget.role == 'superadmin';

  @override
  void initState() {
    super.initState();
    context.read<MemberBloc>().add(LoadMembers());
    NotificationService.checkExpiringMemberships().catchError((e) => debugPrint('Notification error: $e'));
  }

  void _showRemindDialog(String name, String phone, DateTime endDate) {
    final daysLeft = endDate.difference(DateTime.now()).inDays;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Send Reminder?'),
        content: Text('Send a WhatsApp reminder to $name about their membership expiring in $daysLeft day${daysLeft == 1 ? '' : 's'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.message, size: 18),
            label: const Text('WhatsApp'),
            onPressed: () { Navigator.pop(context); _openWhatsApp(name, phone, daysLeft); },
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(String name, String phone, int daysLeft) async {
    String cleanPhone = phone.endsWith('.0') ? phone.substring(0, phone.length - 2) : phone;
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0+'), '');
    if (!cleanPhone.startsWith('973')) cleanPhone = '973$cleanPhone';
    final message = Uri.encodeComponent(
      'Hi $name,\n\nThis is a friendly reminder from Avangard Gym that your membership '
      'will expire in $daysLeft day${daysLeft == 1 ? '' : 's'}.\n\nPlease visit us to renew.\n\nThank you!\nAvangard Gym Team',
    );
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context)?.isDark ?? false;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Men\'s Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => MyApp.of(context)?.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () async {
              await NotificationService.checkExpiringMemberships();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('✅ Notifications checked!'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, isDark),
      body: BlocBuilder<MemberBloc, MemberState>(
        builder: (context, state) {
          final loaded = state is MemberLoaded ? state : null;
          return RefreshIndicator(
            color: Colors.deepOrange,
            onRefresh: () async => context.read<MemberBloc>().add(LoadMembers()),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, loaded, isDark)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (state is MemberLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
                        )
                      else ...[
                        _buildExpiringSection(context, loaded),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MembersScreen(role: widget.role))),
        icon: const Icon(Icons.people_rounded),
        label: const Text('Members', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MemberLoaded? loaded, bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3E0F00), Color(0xFF7B2500), Color(0xFF3E0F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/logo.jpg', width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Avangard Gym', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  Text('Men\'s Section', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _headerStat('Total', loaded?.total ?? 0, Icons.people_rounded, Colors.blue)),
              _vertDivider(),
              Expanded(child: _headerStat('Active', loaded?.active ?? 0, Icons.check_circle_rounded, Colors.green)),
              _vertDivider(),
              Expanded(child: _headerStat('Inactive', loaded?.inactive ?? 0, Icons.cancel_rounded, Colors.red)),
              _vertDivider(),
              Expanded(child: _headerStat('Frozen', loaded?.frozen ?? 0, Icons.ac_unit_rounded, Colors.blueGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text('$count', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      ],
    );
  }

  Widget _vertDivider() => Container(width: 1, height: 48, color: Colors.white.withOpacity(0.2));

  Widget _buildExpiringSection(BuildContext context, MemberLoaded? loaded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              const Text('Expiring Soon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ]),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MembersScreen(role: widget.role))),
              child: const Text('View All', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (loaded == null || loaded.expiringSoon.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.green[400], size: 28),
                const SizedBox(width: 12),
                const Text('No memberships expiring soon', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        else
          ...loaded.expiringSoon.map((member) {
            final daysLeft = member.endDate.difference(DateTime.now()).inDays;
            final isUrgent = daysLeft <= 3;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.withOpacity(0.06) : Colors.orange.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isUrgent ? Colors.red.withOpacity(0.15) : Colors.orange.withOpacity(0.15)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                onTap: () => _showRemindDialog(member.name, member.phone, member.endDate),
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: isUrgent
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : [Colors.orange.shade400, Colors.orange.shade600]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                ),
                title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text(member.phone, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$daysLeft day${daysLeft == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3E0F00), Color(0xFF7B2500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 24, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/logo.jpg', width: 64, height: 64, fit: BoxFit.cover),
                ),
                const SizedBox(height: 14),
                const Text('Avangard Gym', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(isSuperAdmin ? 'Super Admin' : 'Admin',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerItem(context, Icons.dashboard_rounded, 'Dashboard', Colors.deepOrange, () => Navigator.pop(context)),
                _drawerItem(context, Icons.people_rounded, 'Members', Colors.blue, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MembersScreen(role: widget.role)));
                }),
                _drawerItem(context, Icons.bar_chart_rounded, 'Charts & Stats', Colors.purple,
                    isSuperAdmin ? () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ChartsScreen())); } : null,
                    enabled: isSuperAdmin),
                _drawerItem(context, Icons.today_rounded, 'Daily Report', Colors.teal, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyReportScreen()));
                }),
                _drawerItem(context, Icons.sync_rounded, 'Sync from Sheets', Colors.indigo, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportScreen()));
                }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(children: [
                    Container(width: 3, height: 14, decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    Text("WOMEN'S SECTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.pink[400], letterSpacing: 1)),
                  ]),
                ),
                _drawerItem(context, Icons.woman_rounded, "Women's Dashboard", Colors.pink, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WomenDashboardScreen(role: widget.role)));
                }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                _drawerItem(context, Icons.admin_panel_settings_rounded, 'Admin Management', Colors.amber,
                    isSuperAdmin ? () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())); } : null,
                    enabled: isSuperAdmin),
                _drawerItem(context, Icons.history_rounded, 'Audit Log', Colors.grey,
                    isSuperAdmin ? () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditScreen())); } : null,
                    enabled: isSuperAdmin),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20, color: Colors.grey[600]),
                    ),
                    title: Text(isDark ? 'Light Mode' : 'Dark Mode', style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Switch(value: isDark, activeColor: Colors.deepOrange, onChanged: (_) => MyApp.of(context)?.toggleTheme()),
                    onTap: () => MyApp.of(context)?.toggleTheme(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              ),
              title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Color color, VoidCallback? onTap, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        enabled: enabled,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: enabled ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: enabled ? color : Colors.grey),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: enabled ? null : Colors.grey, fontSize: 14)),
        subtitle: !enabled ? const Text('Superadmin only', style: TextStyle(fontSize: 10)) : null,
        onTap: onTap,
        trailing: enabled && onTap != null ? Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[400]) : null,
      ),
    );
  }
}
