import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/services/noti_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<UserData?> firebaseLoginInitializeAds() async {
    //광고 로드
    await MobileAds.instance.initialize();
    UserData? returnUser;

    try {
      //로그인된 유저가 없으면 유저 null 반환
      if (FirebaseAuth.instance.currentUser == null) {
        return returnUser;
      }
      //로그인 된 유저가 있으면 유저 데이터 반환
      else {
        String? uid = FirebaseAuth.instance.currentUser?.uid;
        return await AuthService().getUserData(uid: uid ?? "");
      }
    } catch (e) {
      debugPrint(e.toString());
      return returnUser;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    Future init() async {
      //알림 서비스 초기화
      NotiService.init();

      //알림 권한 요청
      NotiService.requestNotiPermission();

      //파이어베이스 로그인 및 광고 초기화 (로그인 확인)
      final UserData? currentUser = await firebaseLoginInitializeAds();

      //1. 유저 데이터가 null 이면 (로그인 상태가 아니면)
      if (currentUser == null) {
        //1-1. 로그인 페이지로 이동
        context.goNamed(Screen.login);
      }
      //2. 유저 데이터가 반환되면 (로그인 상태이면)
      else {
        //2-1. 유저 데이터 저장 후 메인 화면으로 이동

        context.read<UserDataProvider>().userData = currentUser;

        //2-2. 알림 토큰 최신화
        AuthService().updateNotiToken(currentUser);

        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          // save token to server
          debugPrint("TOKEN: $newToken");
        });

        //2-3. 메인 페이지로 이동
        context.goNamed(Screen.main);

        //종료 중 알림 터치 시
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage? message) async {
          if (message != null) {
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

              var roomData = GroupChatRoomData.fromJson(
                  data.data() as Map<String, dynamic>);

              //채팅방 화면으로 이동
              router.pushNamed(Screen.chatRoom,
                  pathParameters: {"isGroup": "group"}, extra: roomData);
            }
          }
        });
      }
    }

    init();

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: Image.asset(
        'assets/images/${isDark ? "dark_splash.png" : "light_splash.png"}',
        fit: BoxFit.fitHeight,
      ),
    );
  }
}
