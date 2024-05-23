import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/services/noti_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class InitLoadingScreen extends StatefulWidget {
  const InitLoadingScreen({super.key});

  @override
  State<InitLoadingScreen> createState() => _InitLoadingScreenState();
}

class _InitLoadingScreenState extends State<InitLoadingScreen> {
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
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false);
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
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
            (route) => false);
      }
    }

    init();

    return const Placeholder();
  }
}