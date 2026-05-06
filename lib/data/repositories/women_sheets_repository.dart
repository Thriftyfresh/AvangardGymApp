import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants.dart';

class WomenSheetsRepository {
  static const _spreadsheetId = AppConstants.womenSpreadsheetId;
  static const _range = 'A2:R';
  static const _scopes = [SheetsApi.spreadsheetsScope];

  Future<SheetsApi> _getSheetsApi() async {
    final jsonStr = await rootBundle.loadString('assets/serviceAccount.json');
    final credentials = ServiceAccountCredentials.fromJson(json.decode(jsonStr));
    final client = await clientViaServiceAccount(credentials, _scopes);
    return SheetsApi(client);
  }

  // Actual column mapping from sheet:
  // 0: (empty/№)  1: Renew  2: CPR  3: Name  4: Birthday  5: Phone  6: Email
  // 7: Membership  8: Referral  9: Package  10: Start  11: Finish
  // 12: date paid  13: Month paid  14: Recept  15: Benefit  16: Cash  17: Credit card

  Future<WomenSyncResult> syncMembers() async {
    final firestore = FirebaseFirestore.instance;

    final existingSnap = await firestore.collection('women_members').get();
    final existingMap = <String, _ExistingMember>{};
    for (final doc in existingSnap.docs) {
      final cpr = (doc.data()['cpr'] ?? '').toString();
      if (cpr.isNotEmpty) {
        final startDate = (doc.data()['startDate'] as Timestamp?)?.toDate();
        final datePaid = _parseDate((doc.data()['datePaid'] ?? '').toString());
        existingMap[cpr] = _ExistingMember(docId: doc.id, startDate: startDate, datePaid: datePaid);
      }
    }

    final sheetsApi = await _getSheetsApi();
    final response = await sheetsApi.spreadsheets.values.get(_spreadsheetId, _range);
    final rows = response.values;
    if (rows == null || rows.isEmpty) return WomenSyncResult(added: 0, skipped: 0, updated: 0);

    int added = 0;
    int skipped = 0;
    int updated = 0;

    for (final row in rows) {
      if (row.length < 4) { skipped++; continue; }

      final name = _str(row, 3);
      if (name.isEmpty) { skipped++; continue; }

      final cpr = _str(row, 2);
      if (cpr.isEmpty) { skipped++; continue; }

      final startDate = _parseDate(_str(row, 10));
      final endDate = _parseDate(_str(row, 11));

      if (startDate == null || endDate == null) { skipped++; continue; }
      if (startDate.year < 2000 || startDate.year > 2100) { skipped++; continue; }
      if (endDate.year < 2000 || endDate.year > 2100) { skipped++; continue; }

      final today = DateTime.now();

      final memberData = {
        'rowNumber':    _str(row, 0),
        'renew':        _str(row, 1),
        'cpr':          cpr,
        'name':         name,
        'birthday':     _str(row, 4),
        'phone':        _str(row, 5),
        'email':        _str(row, 6),
        'membership':   _str(row, 7),
        'referral':     _str(row, 8),
        'package':      _str(row, 9),
        'startDate':    Timestamp.fromDate(startDate),
        'endDate':      Timestamp.fromDate(endDate),
        'datePaid':     _str(row, 12),
        'monthPaid':    _str(row, 13),
        'recept':       _str(row, 14),
        'benefit':      _str(row, 15),
        'cash':         row.length > 16 ? _str(row, 16) : '',
        'creditCard':   row.length > 17 ? _str(row, 17) : '',
        'status':       endDate.isBefore(today) ? 'inactive' : 'active',
        'createdBy':    'sheets_sync',
        'lastEditedBy': 'sheets_sync',
      };

      if (!existingMap.containsKey(cpr)) {
        final ref = await firestore.collection('women_members').add(memberData);
        existingMap[cpr] = _ExistingMember(docId: ref.id, startDate: startDate, datePaid: _parseDate(_str(row, 12)));
        added++;
      } else {
        final existing = existingMap[cpr]!;
        if (existing.docId.isEmpty) { skipped++; continue; }
        final rowDatePaid = _parseDate(_str(row, 12));
        final isNewer = (rowDatePaid != null && existing.datePaid != null && rowDatePaid.isAfter(existing.datePaid!)) ||
                        (rowDatePaid != null && existing.datePaid == null) ||
                        (startDate.isAfter(existing.startDate ?? DateTime(2000)));
        if (isNewer) {
          final docRef = firestore.collection('women_members').doc(existing.docId);
          final currentDoc = await docRef.get();
          if (currentDoc.exists) {
            final currentData = currentDoc.data()!;
            final currentEnd = (currentData['endDate'] as Timestamp?)?.toDate();
            if (currentEnd == null || endDate != currentEnd) {
              await docRef.collection('history').add({
                'membership':   currentData['membership'] ?? '',
                'package':      currentData['package'] ?? '',
                'startDate':    currentData['startDate'],
                'endDate':      currentData['endDate'],
                'datePaid':     currentData['datePaid'] ?? '',
                'monthPaid':    currentData['monthPaid'] ?? '',
                'recept':       currentData['recept'] ?? '',
                'benefit':      currentData['benefit'] ?? '',
                'cash':         currentData['cash'] ?? '',
                'creditCard':   currentData['creditCard'] ?? '',
                'status':       'inactive',
              });
            }
            await docRef.update(memberData);
            existingMap[cpr] = _ExistingMember(docId: existing.docId, startDate: startDate, datePaid: rowDatePaid);
            updated++;
          }
        } else {
          skipped++;
        }
      }
    }

    return WomenSyncResult(added: added, skipped: skipped, updated: updated);
  }

  Future<void> addMemberToSheet({
    required String cpr,
    required String name,
    required String birthday,
    required String phone,
    required String email,
    required String membership,
    required String referral,
    required String package,
    required DateTime startDate,
    required DateTime endDate,
    required String recept,
    required String benefit,
    required String cash,
    required String creditCard,
  }) async {
    final sheetsApi = await _getSheetsApi();

    // Find last row by scanning column D (Name)
    final existing = await sheetsApi.spreadsheets.values.get(_spreadsheetId, 'D2:D10000');
    int lastDataRow = 1;
    if (existing.values != null) {
      lastDataRow = existing.values!.length + 1;
    }
    final nextRow = lastDataRow + 1;

    // Match exact column order: №, Renew, CPR, Name, Birthday, Phone, Email,
    // Membership, Referral, Package, Start, Finish, date paid, Month paid,
    // Recept, Benefit, Cash, Credit card
    final row = [
      '',           // №
      '',           // Renew
      cpr,          // CPR
      name,         // Name
      birthday,     // Birthday
      phone,        // Phone
      email,        // Email
      membership,   // Membership
      referral,     // Client knows about us from?
      package,      // Package
      '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',  // Start
      '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',        // Finish
      '',           // date paid
      '',           // Month paid
      recept,       // Recept
      benefit,      // Benefit
      cash,         // Cash
      creditCard,   // Credit card
    ];

    await sheetsApi.spreadsheets.values.update(
      ValueRange(values: [row]),
      _spreadsheetId,
      'A$nextRow:R$nextRow',
      valueInputOption: 'USER_ENTERED',
    );
  }

  String _str(List row, int index) {
    if (index >= row.length) return '';
    return row[index]?.toString().trim() ?? '';
  }

  DateTime? _parseDate(String val) {
    if (val.isEmpty) return null;
    // Try ISO format first: 2026-05-06
    try { return DateTime.parse(val); } catch (_) {}
    // dd/MM/yyyy format (used in both sheets)
    try {
      final parts = val.split('/');
      if (parts.length == 3) {
        final day   = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year  = int.parse(parts[2]);
        if (year > 100 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          return DateTime(year, month, day);
        }
      }
    } catch (_) {}
    return null;
  }
}

class _ExistingMember {
  final String docId;
  final DateTime? startDate;
  final DateTime? datePaid;
  _ExistingMember({required this.docId, this.startDate, this.datePaid});
}

class WomenSyncResult {
  final int added;
  final int skipped;
  final int updated;
  WomenSyncResult({required this.added, required this.skipped, required this.updated});
}
