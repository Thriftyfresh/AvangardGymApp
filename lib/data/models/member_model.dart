import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MemberModel extends Equatable {
  final String id;
  final String rowNumber;
  final String renew;
  final String cpr;
  final String name;
  final String birthday;
  final String phone;
  final String membership;
  final String referral;
  final String package;
  final DateTime startDate;
  final DateTime endDate;
  final String datePaid;
  final String monthPaid;
  final String recept;
  final String benefit;
  final String cash;
  final String creditCard;
  final String status; // active | inactive | frozen
  final String createdBy;
  final String lastEditedBy;

  const MemberModel({
    required this.id,
    this.rowNumber = '',
    this.renew = '',
    this.cpr = '',
    required this.name,
    this.birthday = '',
    this.phone = '',
    this.membership = '',
    this.referral = '',
    this.package = '',
    required this.startDate,
    required this.endDate,
    this.datePaid = '',
    this.monthPaid = '',
    this.recept = '',
    this.benefit = '',
    this.cash = '',
    this.creditCard = '',
    this.status = 'active',
    this.createdBy = '',
    this.lastEditedBy = '',
  });

  Map<String, dynamic> toMap() => {
    'rowNumber':    rowNumber,
    'renew':        renew,
    'cpr':          cpr,
    'name':         name,
    'birthday':     birthday,
    'phone':        phone,
    'membership':   membership,
    'referral':     referral,
    'package':      package,
    'startDate':    Timestamp.fromDate(startDate),
    'endDate':      Timestamp.fromDate(endDate),
    'datePaid':     datePaid,
    'monthPaid':    monthPaid,
    'recept':       recept,
    'benefit':      benefit,
    'cash':         cash,
    'creditCard':   creditCard,
    'status':       status,
    'createdBy':    createdBy,
    'lastEditedBy': lastEditedBy,
  };

  factory MemberModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      return DateTime.now();
    }

    return MemberModel(
      id:           id,
      rowNumber:    map['rowNumber'] ?? '',
      renew:        map['renew'] ?? '',
      cpr:          map['cpr'] ?? '',
      name:         map['name'] ?? '',
      birthday:     map['birthday'] ?? '',
      phone:        map['phone'] ?? '',
      membership:   map['membership'] ?? '',
      referral:     map['referral'] ?? '',
      package:      map['package'] ?? '',
      startDate:    parseDate(map['startDate']),
      endDate:      parseDate(map['endDate']),
      datePaid:     map['datePaid'] ?? '',
      monthPaid:    map['monthPaid'] ?? '',
      recept:       map['recept'] ?? '',
      benefit:      map['benefit'] ?? '',
      cash:         map['cash'] ?? '',
      creditCard:   map['creditCard'] ?? '',
      status:       map['status'] ?? 'active',
      createdBy:    map['createdBy'] ?? '',
      lastEditedBy: map['lastEditedBy'] ?? '',
    );
  }

  MemberModel copyWith({
    String? rowNumber, String? renew, String? cpr, String? name,
    String? birthday, String? phone, String? membership, String? referral,
    String? package, DateTime? startDate, DateTime? endDate, String? datePaid,
    String? monthPaid, String? recept, String? benefit, String? cash,
    String? creditCard, String? status, String? lastEditedBy,
  }) => MemberModel(
    id:           id,
    rowNumber:    rowNumber ?? this.rowNumber,
    renew:        renew ?? this.renew,
    cpr:          cpr ?? this.cpr,
    name:         name ?? this.name,
    birthday:     birthday ?? this.birthday,
    phone:        phone ?? this.phone,
    membership:   membership ?? this.membership,
    referral:     referral ?? this.referral,
    package:      package ?? this.package,
    startDate:    startDate ?? this.startDate,
    endDate:      endDate ?? this.endDate,
    datePaid:     datePaid ?? this.datePaid,
    monthPaid:    monthPaid ?? this.monthPaid,
    recept:       recept ?? this.recept,
    benefit:      benefit ?? this.benefit,
    cash:         cash ?? this.cash,
    creditCard:   creditCard ?? this.creditCard,
    status:       status ?? this.status,
    createdBy:    createdBy,
    lastEditedBy: lastEditedBy ?? this.lastEditedBy,
  );

  @override
  List<Object?> get props => [id, cpr, name, phone, status, startDate, endDate];
}
