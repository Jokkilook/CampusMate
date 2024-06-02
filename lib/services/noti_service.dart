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
        payloadString = jsonEncode(message.data);
      }
      //그룹 채팅 알림일 때,
      if (message.data["type"] == "groupChat") {
        payloadString = jsonEncode(message.data);
      }
      //일반 게시판 댓글, 답글 알림일 때,
      if (message.data["type"] == "generalPost") {
        payloadString =
            jsonEncode({"type": "general", "id": message.data["id"]});
      }
      //익명 게시판 댓글, 답글 알림일 때,
      if (message.data["type"] == "anonyPost") {
        jsonEncode({"type": "anonymous", "id": message.data["id"]});
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
            .doc(message.data["id"])
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
            .doc(message.data["id"])
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
            .doc(message.data["id"])
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
            .doc(message.data["id"])
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
        const AndroidInitializationSettings("mipmap/ic_noti");

    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestCriticalPermission: false);

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    //포그라운드 알림 클릭 시 행동
    await notiPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        try {
          String payloadString = details.payload!;
          Map<String, dynamic> json = jsonDecode(payloadString);
          //1:1 채팅방 알림이면
          if (json["type"] == "chat") {
            //채팅방 데이터 불러오기
            var data = await FirebaseFirestore.instance
                .collection("schools/${json["school"]}/chats")
                .doc(json["id"])
                .get();
            ChatRoomData roomData =
                ChatRoomData.fromJson(data.data() as Map<String, dynamic>);

            //1:1 채팅방 화면으로 이동
            router.pushNamed(Screen.chatRoom,
                pathParameters: {"isGroup": "one"}, extra: roomData);

            return;
          }
          //그룹 채팅방 알림이면
          if (json["type"] == "groupChat") {
            //그룹 채팅방 데이터 불러오기
            var data = await FirebaseFirestore.instance
                .collection("schools/${json["school"]}/groupChats")
                .doc(json["id"])
                .get();

            GroupChatRoomData roomData =
                GroupChatRoomData.fromJson(data.data() as Map<String, dynamic>);

            //그룹 채팅방 화면으로 이동
            router.pushNamed(Screen.chatRoom,
                pathParameters: {"isGroup": "group"}, extra: roomData);

            return;
          }
          //일반 게시글 관련 알림이면
          if (json["type"] == "general") {
            //일반 게시글 화면으로 이동
            router.pushNamed(
              Screen.post,
              pathParameters: {"postId": json["id"] ?? ""},
            );
            return;
          }
          //익명 게시글 관련 알림이면
          if (json["type"] == "anonymous") {
            //익명 게시글 화면으로 이동
            router.pushNamed(
              Screen.anonymousPost,
              pathParameters: {"postId": json["id"] ?? ""},
            );
            return;
          }
        } catch (e) {
          debugPrint("${e.hashCode}: $e");
        }
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

  ///로컬 알림 보내기
  static Future showNoti(
      {required String title,
      required String content,
      String payload = ""}) async {
    const AndroidNotificationDetails androidNotiDetails =
        AndroidNotificationDetails(
      "channel id",
      "channel name",
      channelDescription: "channel description",
      importance: Importance.max,
      priority: Priority.max,
      showWhen: false,
      actions: [AndroidNotificationAction("1", "열기", showsUserInterface: true)],
    );

    const NotificationDetails notiDetails = NotificationDetails(
        android: androidNotiDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1));

    await notiPlugin.show(0, title, content, notiDetails, payload: payload);
  }

  ///푸쉬 알림 보내는 함수<br>
  ///required [targetToken] : 받을 유저의 기기 토큰<br>
  ///required [title] : 알림의 제목<br>
  ///required [content] : 알림의 내용<br>
  //////required [data] : 같이 전송할 데이터 Map<String, dynamic>
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

  ///UID로 알림 보내기
  //////required [targetUID] : 받을 유저의 UID<br>
  ///required [title] : 알림의 제목<br>
  ///required [content] : 알림의 내용<br>
  //////required [data] : 같이 전송할 데이터 Map<String, dynamic>
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
