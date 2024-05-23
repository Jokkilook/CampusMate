import 'dart:convert';
import 'dart:io';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotiService {
  NotiService._();

  static FirebaseMessaging fireMessage = FirebaseMessaging.instance;

  static FlutterLocalNotificationsPlugin notiPlugin =
      FlutterLocalNotificationsPlugin();

  ///알림 서비스 초기화
  static init() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("MESSAGE DATA: ${message.data}");
    });

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
  }

  ///알림 권한 요청
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

  ///푸쉬 알림 보내는 함수<br>
  ///required [targetToken] : 받을 유저의 기기 토큰<br>
  ///required [title] : 알림의 제목<br>
  ///required [content] : 알림의 내용
  static Future sendNoti({
    required String targetToken,
    required String title,
    required String content,
    Map<String, dynamic>? data,
  }) async {
    final jsonCredentials =
        await rootBundle.loadString("assets/data/secretKey.json");

    final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);

    final client = await auth.clientViaServiceAccount(
        creds, ['https://www.googleapis.com/auth/cloud-platform']);

    final notificationData = {
      'message': {
        //받을 사람 기기토큰
        'token': targetToken,
        'data': data,

        'notification': {
          'title': title,
          'body': content,
        }
      }
    };

    final response = await client.post(
      Uri.parse(
          "https://fcm.googleapis.com/v1/projects/classmate-81447/messages:send"),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(notificationData),
    );

    debugPrint(
        "RESULT: ${response.statusCode}: ${response.reasonPhrase} ${response.body}");
  }
}
