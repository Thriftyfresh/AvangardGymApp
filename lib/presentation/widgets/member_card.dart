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
    required this.onDelete,
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

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(member.status);
    final daysLeft = member.endDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor.withOpacity(0.8), statusColor.withOpacity(0.4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(_initials(member.name),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (member.phone.isNotEmpty) ...[
                            Icon(Icons.phone_outlined, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 3),
                            Text(member.phone, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                            const SizedBox(width: 8),
                          ],
                          if (member.package.isNotEmpty)
                            Text('• ${member.package}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              member.status.toUpperCase(),
                              style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            daysLeft < 0 ? 'Expired ${daysLeft.abs()}d ago' : '$daysLeft days left',
                            style: TextStyle(
                              fontSize: 11,
                              color: daysLeft < 0 ? Colors.red[400] : daysLeft <= 7 ? Colors.orange[400] : Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[500], size: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit')])),
                    PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red[400]), const SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red[400]))])),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
