import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> checkExpiringMemberships() async {
    await init();
    final now = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    final snap = await firestore
        .collection('members')
        .where('status', isEqualTo: 'active')
        .get();

    final expiring = <Map<String, dynamic>>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final endDateRaw = data['endDate'];
      if (endDateRaw == null) continue;
      final endDate = (endDateRaw as Timestamp).toDate();
      final daysLeft = endDate.difference(now).inDays;
      if (daysLeft == 7 || daysLeft == 3 || daysLeft == 1 || daysLeft == 0) {
        expiring.add({'name': data['name'] ?? 'Member', 'daysLeft': daysLeft});
      }
    }

    if (expiring.isEmpty) return;

    // Send a single summary notification instead of one per member
    final count = expiring.length;
    final first = expiring.first;
    final title = count == 1
        ? (first['daysLeft'] == 0 ? '🔴 Membership Expired Today' : '⚠️ Membership Expiring Soon')
        : '⚠️ $count Memberships Expiring Soon';
    final body = count == 1
        ? '${first['name']}\' membership ${first['daysLeft'] == 0 ? 'expired today' : 'expires in ${first['daysLeft']} day${first['daysLeft'] == 1 ? '' : 's'}'}!'
        : expiring.take(3).map((e) => '${e['name']} (${e['daysLeft'] == 0 ? 'today' : '${e['daysLeft']}d'})').join(', ') + (count > 3 ? ' +${count - 3} more' : '');

    await _sendNotification(id: 0, title: title, body: body);
  }

  static Future<void> _sendNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'membership_channel',
      'Membership Alerts',
      channelDescription: 'Alerts for expiring memberships',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);
    await _plugin.show(id, title, body, details);
  }
}
