import 'dart:convert';
import 'dart:io';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotiService {
  NotiService._();

  static FirebaseMessaging fireMessage = FirebaseMessaging.instance;
  static AuthService authService = AuthService();

  static FlutterLocalNotificationsPlugin notiPlugin =
      FlutterLocalNotificationsPlugin();

  ///알림 서비스 초기화
  static init() async {
    //포그라운드에서 알림 수신 시
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      String payloadString = "";

      //1:1 채팅 알림일 때,
      if (message.data["type"] == "chat") {
        var data = await FirebaseFirestore.instance
            .collection("schools/${message.data["school"]}/chats")
            .doc(message.data["roomId"])
            .get();

        //타임스탬프가 json인코딩하는데 문제
        var roomData =
            ChatRoomData.fromJson(data.data() as Map<String, dynamic>);
        payloadString = jsonEncode(roomData.toJson());
      }
      //그룹 채팅 알림일 때,
      if (message.data["type"] == "groupChat") {
        var data = await FirebaseFirestore.instance
            .collection("schools/${message.data["school"]}/groupChats")
            .doc(message.data["roomId"])
            .get();

        var roomData =
            GroupChatRoomData.fromJson(data.data() as Map<String, dynamic>);
        payloadString = jsonEncode(roomData.toJson());
      }

      showNoti(
        title: message.notification?.title ?? "",
        content: message.notification?.body ?? "",
        payload: payloadString,
      );
    });

    //백그라운드 알림 터치로 어플 실행 시
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      //1:1 채팅 알림일 때,
      if (message.data["type"] == "chat") {
        var data = await FirebaseFirestore.instance
            .collection("schools/${message.data["school"]}/chats")
            .doc(message.data["roomId"])
            .get();

        var roomData =
            ChatRoomData.fromJson(data.data() as Map<String, dynamic>);

        router.pushNamed(Screen.chatRoom,
            pathParameters: {"isGroup": "one"}, extra: roomData);
      }
      //그룹 채팅 알림일 때,
      if (message.data["type"] == "groupChat") {
        var data = await FirebaseFirestore.instance
            .collection("schools/${message.data["school"]}/groupChats")
            .doc(message.data["roomId"])
            .get();

        var roomData =
            GroupChatRoomData.fromJson(data.data() as Map<String, dynamic>);

        //채팅방 화면으로 이동
        router.pushNamed(Screen.chatRoom,
            pathParameters: {"isGroup": "group"}, extra: roomData);
      }
      //일반 게시판 댓글, 답글 알림일 때,
      if (message.data["type"] == "generalPost") {
        var data = await FirebaseFirestore.instance
            .collection("schools/${message.data["school"]}/generalPosts")
            .doc(message.data["postId"])
            .get();

        var postData = PostData.fromJson(data.data() as Map<String, dynamic>);

        //일반 게시글 화면으로 이동
        router.pushNamed(
          Screen.post,
          pathParameters: {"postId": postData.postId ?? ""},
        );
      }
      //익명 게시판 댓글, 답글 알림일 때,
      if (message.data["type"] == "anonyPost") {
        var data = await FirebaseFirestore.instance
            .collection("schools/${message.data["school"]}/anonymousPosts")
            .doc(message.data["postId"])
            .get();

        var postData = PostData.fromJson(data.data() as Map<String, dynamic>);

        //일반 게시글 화면으로 이동
        router.pushNamed(
          Screen.anonymousPost,
          pathParameters: {"postId": postData.postId ?? ""},
        );
      }
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

    await notiPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        String payloadString = details.payload!;
        ChatRoomData roomData =
            ChatRoomData.fromJson(jsonDecode(payloadString));

        router.pushNamed(Screen.chatRoom,
            pathParameters: {"isGroup": "one"}, extra: roomData);
      },
    );
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

  static Future showNoti(
      {required String title,
      required String content,
      String payload = ""}) async {
    const AndroidNotificationDetails androidNotiDetails =
        AndroidNotificationDetails("channel id", "channel name",
            channelDescription: "channel description",
            importance: Importance.max,
            priority: Priority.max,
            showWhen: false);

    const NotificationDetails notiDetails = NotificationDetails(
        android: androidNotiDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1));

    await notiPlugin.show(0, title, content, notiDetails, payload: "Asd");
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

  static Future sendNotiToUser(
      {required String targetUID,
      required String title,
      required String content,
      Map<String, dynamic>? data}) async {
    String token = await authService.getUserNotiToken(targetUID);

    await sendNoti(
        targetToken: token, content: content, title: title, data: data);
  }
}
