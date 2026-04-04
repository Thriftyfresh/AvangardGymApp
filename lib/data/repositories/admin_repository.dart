import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_model.dart';
import '../../core/constants.dart';

class AdminRepository {
  final _col = FirebaseFirestore.instance.collection('admins');

  Stream<List<AdminModel>> getAdmins() {
    return _col.orderBy('name').snapshots().map((snap) =>
        snap.docs.map((doc) => AdminModel.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> addAdmin({
    required String email,
    required String name,
    required String role,
    required String currentAdminEmail,
    required String currentAdminPassword,
  }) async {
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: AppConstants.defaultAdminPassword,
      );

      await _col.doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Re-sign in as the current admin
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: currentAdminEmail,
        password: currentAdminPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('An account with this email already exists.');
      }
      rethrow;
    }
  }

  Future<void> deleteAdmin(String adminId) async {
    await _col.doc(adminId).delete();
  }

  Future<void> updateRole(String adminId, String role) async {
    await _col.doc(adminId).update({'role': role});
  }

  Future<AdminModel?> getCurrentAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return AdminModel.fromMap(doc.id, doc.data()!);
  }
}
