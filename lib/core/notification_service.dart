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

    int notifId = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      final endDateRaw = data['endDate'];
      if (endDateRaw == null) continue;
      final endDate = (endDateRaw as Timestamp).toDate();
      final daysLeft = endDate.difference(now).inDays;
      final name = data['name'] ?? 'Member';

      if (daysLeft == 7 || daysLeft == 3 || daysLeft == 1) {
        await _sendNotification(
          id: notifId++,
          title: '⚠️ Membership Expiring Soon',
          body: '$name\'s membership expires in $daysLeft day${daysLeft == 1 ? '' : 's'}!',
        );
      } else if (daysLeft == 0) {
        await _sendNotification(
          id: notifId++,
          title: '🔴 Membership Expired Today',
          body: '$name\'s membership has expired today!',
        );
      }
    }
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
