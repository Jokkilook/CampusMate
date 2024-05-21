import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiTest {
  NotiTest._();

  static FlutterLocalNotificationsPlugin notiPlugin =
      FlutterLocalNotificationsPlugin();

  static init() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings("mipmap/ic_launcher");

    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestCriticalPermission: false);

    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await notiPlugin.initialize(initializationSettings);

    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM-TOKEN : $fcmToken");
  }

  static requestNotiPermission() {
    if (Platform.isAndroid) {
      notiPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    if (Platform.isIOS) {
      notiPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static Future showNoti() async {
    const AndroidNotificationDetails androidNotiDetails =
        AndroidNotificationDetails("channel id", "channel name",
            channelDescription: "channel description",
            importance: Importance.max,
            priority: Priority.max,
            showWhen: false);

    const NotificationDetails notiDetails = NotificationDetails(
        android: androidNotiDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1));

    await notiPlugin.show(0, "TEST", "TEST NOTI", notiDetails);
  }
}
