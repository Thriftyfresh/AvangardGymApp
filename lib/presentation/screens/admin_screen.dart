import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../bloc/admin/admin_bloc.dart';
import '../../bloc/admin/admin_event.dart';
import '../../bloc/admin/admin_state.dart';
import '../../data/models/admin_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadAdmins());
  }

  void _showAddAdminDialog() {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String role = 'admin';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Admin'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                  items: ['admin', 'superadmin'].map((r) =>
                      DropdownMenuItem(value: r, child: Text(r == 'superadmin' ? 'Super Admin' : 'Admin'))).toList(),
                  onChanged: (v) => setDialogState(() => role = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Your Password (to confirm)', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                const Text('New admin default password: Avangard@123', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) return;
                final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
                context.read<AdminBloc>().add(AddAdmin(
                  email: emailCtrl.text.trim(),
                  name: nameCtrl.text.trim(),
                  role: role,
                  currentAdminEmail: currentEmail,
                  currentAdminPassword: passwordCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AdminModel admin) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Admin'),
        content: Text('Remove ${admin.name} as admin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AdminBloc>().add(DeleteAdmin(admin.id));
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Admin Management')),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is! AdminLoaded) return const SizedBox();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.admins.length,
            itemBuilder: (context, index) {
              final admin = state.admins[index];
              final isSuperAdmin = admin.role == 'superadmin';
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSuperAdmin ? Colors.deepOrange.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                    child: Icon(
                      isSuperAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: isSuperAdmin ? Colors.deepOrange : Colors.blue,
                    ),
                  ),
                  title: Text(admin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(admin.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSuperAdmin ? Colors.deepOrange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isSuperAdmin ? 'Super Admin' : 'Admin',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSuperAdmin ? Colors.deepOrange : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PopupMenuButton(
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(isSuperAdmin ? 'Set as Admin' : 'Set as Super Admin'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Remove', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'toggle') {
                            context.read<AdminBloc>().add(UpdateAdminRole(
                              adminId: admin.id,
                              role: isSuperAdmin ? 'admin' : 'superadmin',
                            ));
                          } else if (value == 'delete') {
                            _confirmDelete(admin);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAdminDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
