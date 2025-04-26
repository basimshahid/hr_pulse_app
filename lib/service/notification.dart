import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hr_pulse_app/main.dart';

Future<void> showLocalNotification({
  required String title,
  required String body,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'hr_pulse_channel',
    'HR Pulse Alerts',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
  );
}

Future<void> checkLatenessAndNotify(String userId, int threshold) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final userDoc = await userRef.get();

  if (!userDoc.exists) return;

  final fullName = userDoc['fullName'] ?? 'Employee';
  final lateCount = userDoc['lateCount'] ?? 0;

  if (lateCount >= threshold) {
    await sendNotification(
      title: "Lateness Alert",
      body: "$fullName has reached $lateCount late entries.",
    );
  }
}

Future<void> checkLeaveBalanceAndNotify(String userId, int minThreshold) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final userDoc = await userRef.get();

  if (!userDoc.exists) return;

  final fullName = userDoc['fullName'] ?? 'Employee';
  final leaveBalance = Map<String, dynamic>.from(userDoc['leaveBalance']);

  for (var type in ['annual', 'sick', 'withoutPay']) {
    final count = leaveBalance[type] ?? 0;
    if (count < minThreshold) {
      await sendNotification(
        title: "Leave Balance Low",
        body: "$fullName has low $type leave: only $count day(s) left.",
      );
    }
  }
}

Future<void> sendNotification({
  required String title,
  required String body,
}) async {
  await FirebaseFirestore.instance.collection('notifications').add({
    'title': title,
    'body': body,
    'timestamp': Timestamp.now(),
  });

  await showLocalNotification(title: title, body: body);
}
