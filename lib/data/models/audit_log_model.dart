import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLog {
  final String id;
  final String adminEmail;
  final String action; // created | updated | deleted | imported | synced
  final String memberName;
  final String memberId;
  final String details;
  final DateTime timestamp;

  const AuditLog({
    required this.id,
    required this.adminEmail,
    required this.action,
    this.memberName = '',
    this.memberId = '',
    this.details = '',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'adminEmail': adminEmail,
    'action': action,
    'memberName': memberName,
    'memberId': memberId,
    'details': details,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory AuditLog.fromMap(String id, Map<String, dynamic> map) => AuditLog(
    id: id,
    adminEmail: map['adminEmail'] ?? '',
    action: map['action'] ?? '',
    memberName: map['memberName'] ?? '',
    memberId: map['memberId'] ?? '',
    details: map['details'] ?? '',
    timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
