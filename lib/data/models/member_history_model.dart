import 'package:cloud_firestore/cloud_firestore.dart';

class MemberHistory {
  final String id;
  final String membership;
  final String package;
  final DateTime startDate;
  final DateTime endDate;
  final String datePaid;
  final String monthPaid;
  final String recept;
  final String benefit;
  final String cash;
  final String creditCard;
  final String status;

  const MemberHistory({
    required this.id,
    this.membership = '',
    this.package = '',
    required this.startDate,
    required this.endDate,
    this.datePaid = '',
    this.monthPaid = '',
    this.recept = '',
    this.benefit = '',
    this.cash = '',
    this.creditCard = '',
    this.status = 'inactive',
  });

  factory MemberHistory.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      return DateTime.now();
    }
    return MemberHistory(
      id: id,
      membership: map['membership'] ?? '',
      package: map['package'] ?? '',
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      datePaid: map['datePaid'] ?? '',
      monthPaid: map['monthPaid'] ?? '',
      recept: map['recept'] ?? '',
      benefit: map['benefit'] ?? '',
      cash: map['cash'] ?? '',
      creditCard: map['creditCard'] ?? '',
      status: map['status'] ?? 'inactive',
    );
  }
}
