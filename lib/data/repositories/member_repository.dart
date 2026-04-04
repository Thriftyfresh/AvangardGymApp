import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';
import 'sheets_repository.dart';
import 'audit_repository.dart';

class MemberRepository {
  final _col = FirebaseFirestore.instance.collection('members');
  final _sheets = SheetsRepository();

  Future<List<MemberModel>> getMembers() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs.map((doc) => MemberModel.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> addMember(MemberModel member) async {
    final ref = await _col.add(member.toMap());
    await AuditRepository.log(
      action: 'created',
      memberName: member.name,
      memberId: ref.id,
      details: 'Added new member: ${member.name} (CPR: ${member.cpr})',
    );
    // Also add to Google Sheet
    try {
      await _sheets.addMemberToSheet(
        cpr: member.cpr,
        name: member.name,
        birthday: member.birthday,
        phone: member.phone,
        membership: member.membership,
        referral: member.referral,
        package: member.package,
        startDate: member.startDate,
        endDate: member.endDate,
        recept: member.recept,
        benefit: member.benefit,
        cash: member.cash,
        creditCard: member.creditCard,
      );
    } catch (e) {
      print('Sheet sync error: $e');
    }
  }

  Future<void> updateMember(MemberModel member) async {
    await _col.doc(member.id).update(member.toMap());
    await AuditRepository.log(
      action: 'updated',
      memberName: member.name,
      memberId: member.id,
      details: 'Updated member: ${member.name}',
    );
  }

  Future<void> deleteMember(String id) async {
    final doc = await _col.doc(id).get();
    final name = doc.data()?['name'] ?? 'Unknown';
    await _col.doc(id).delete();
    await AuditRepository.log(
      action: 'deleted',
      memberName: name,
      memberId: id,
      details: 'Deleted member: $name',
    );
  }
}
