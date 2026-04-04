import 'package:flutter/material.dart';
import '../../data/models/member_model.dart';

class MemberCard extends StatelessWidget {
  final MemberModel member;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onTap;

  const MemberCard({
    super.key,
    required this.member,
    required this.onEdit,
    this.onDelete,
    required this.onTap,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'active':   return Colors.green;
      case 'inactive': return Colors.red;
      case 'frozen':   return Colors.blueGrey;
      default:         return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = member.endDate.difference(DateTime.now()).inDays;
    final statusCol = _statusColor(member.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: statusCol.withOpacity(0.15),
                child: Icon(Icons.person_rounded, color: statusCol, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 3),
                    if (member.cpr.isNotEmpty)
                      Text('CPR: ${member.cpr}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    if (member.phone.isNotEmpty)
                      Text('📞 ${member.phone}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusCol.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            member.status.toUpperCase(),
                            style: TextStyle(fontSize: 10, color: statusCol, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          daysLeft < 0 ? 'Expired' : '$daysLeft days left',
                          style: TextStyle(fontSize: 11, color: daysLeft <= 7 ? Colors.orange : Colors.grey[500]),
                        ),
                        if (member.membership.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text('• ${member.membership}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (onDelete != null)
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete' && onDelete != null) onDelete!();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
