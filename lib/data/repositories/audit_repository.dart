import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/audit_log_model.dart';

class AuditRepository {
  final _col = FirebaseFirestore.instance.collection('audit_logs');

  Future<List<AuditLog>> getLogs({int limit = 100}) async {
    final snap = await _col.orderBy('timestamp', descending: true).limit(limit).get();
    return snap.docs.map((doc) => AuditLog.fromMap(doc.id, doc.data())).toList();
  }

  static Future<void> log({
    required String action,
    String memberName = '',
    String memberId = '',
    String details = '',
  }) async {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'unknown';
    await FirebaseFirestore.instance.collection('audit_logs').add({
      'adminEmail': email,
      'action': action,
      'memberName': memberName,
      'memberId': memberId,
      'details': details,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
  }
}
