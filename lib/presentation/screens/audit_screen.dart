import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audit/audit_bloc.dart';
import '../../bloc/audit/audit_event.dart';
import '../../bloc/audit/audit_state.dart';
import '../../data/models/audit_log_model.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuditBloc>().add(LoadAuditLogs());
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'created':  return Icons.person_add_rounded;
      case 'updated':  return Icons.edit_rounded;
      case 'deleted':  return Icons.delete_rounded;
      case 'imported': return Icons.upload_file_rounded;
      case 'synced':   return Icons.sync_rounded;
      default:         return Icons.info_rounded;
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'created':  return Colors.green;
      case 'updated':  return Colors.blue;
      case 'deleted':  return Colors.red;
      case 'imported': return Colors.orange;
      case 'synced':   return Colors.teal;
      default:         return Colors.grey;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AuditBloc>().add(LoadAuditLogs()),
          ),
        ],
      ),
      body: BlocBuilder<AuditBloc, AuditState>(
        builder: (context, state) {
          if (state is AuditLoading) return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          if (state is AuditError) return Center(child: Text(state.message));
          if (state is! AuditLoaded) return const SizedBox();

          if (state.logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No activity yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.logs.length,
            itemBuilder: (context, index) {
              final log = state.logs[index];
              final color = _actionColor(log.action);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: color.withOpacity(0.15),
                        child: Icon(_actionIcon(log.action), color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    log.action.toUpperCase(),
                                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                Text(_timeAgo(log.timestamp), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(log.details, style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('by ${log.adminEmail}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
