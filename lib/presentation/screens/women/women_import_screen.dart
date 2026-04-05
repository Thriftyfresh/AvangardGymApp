import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/women/women_sync_bloc.dart';
import '../../../bloc/women/women_member_bloc.dart';
import '../../../bloc/sync/sync_event.dart';
import '../../../bloc/sync/sync_state.dart';
import '../../../bloc/member/member_event.dart';

class WomenImportScreen extends StatelessWidget {
  const WomenImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink, brightness: Theme.of(context).brightness),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sync Women Members'),
          backgroundColor: Colors.pink.shade600,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<WomenSyncBloc, SyncState>(
          listener: (context, state) {
            if (state is SyncSuccess) {
              context.read<WomenMemberBloc>().add(LoadMembers());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('✅ Added ${state.added}, updated ${state.updated}, skipped ${state.skipped}'),
                backgroundColor: Colors.green,
              ));
            } else if (state is SyncError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: Colors.red,
              ));
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_sync, size: 80, color: Colors.pink),
                  const SizedBox(height: 24),
                  const Text('Sync Women Members', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    'Fetch new members from the Women\'s Google Sheet. Existing members (matched by CPR) will be updated.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  if (state is SyncLoading)
                    const Column(children: [
                      CircularProgressIndicator(color: Colors.pink),
                      SizedBox(height: 16),
                      Text('Syncing...'),
                    ])
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.sync),
                        label: const Text('Sync Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => context.read<WomenSyncBloc>().add(SyncFromSheets()),
                      ),
                    ),
                    if (state is SyncSuccess) ...[
                      const SizedBox(height: 24),
                      Card(
                        color: Colors.pink[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(children: [
                                Text('${state.added}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                                const Text('Added'),
                              ]),
                              Column(children: [
                                Text('${state.updated}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                                const Text('Updated'),
                              ]),
                              Column(children: [
                                Text('${state.skipped}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const Text('Skipped'),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
