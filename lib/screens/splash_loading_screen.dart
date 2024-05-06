import 'package:campusmate/firebase_options.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/screen_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class SplashLoadingScreen extends StatefulWidget {
  const SplashLoadingScreen({super.key});

  @override
  State<SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<SplashLoadingScreen> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Map<String, QuerySnapshot<Object>> chattingCache = {};

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void getChattingInitData() async {}

  // Future<void> handlBackgroundMessage(RemoteMessage message) async {
  //   print(">>>>>>>>>${message.notification?.title}");
  //   print(">>>>>>>>>${message.notification?.body}");
  //   print(">>>>>>>>>${message.data}");
  // }

  //로딩 초기 작업
  void initialize() async {
    String uid = "";
    User user;

    //광고 로드
    await MobileAds.instance.initialize();

    try {
      //파이어베이스 연결
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false);
        return;
      } else {
        user = FirebaseAuth.instance.currentUser!;
        uid = user.uid;
      }

      // final fcm = FirebaseMessaging.instance;
      // final token = await fcm.getToken();
      // print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$token");
      // FirebaseMessaging.onBackgroundMessage(
      //   (message) => handlBackgroundMessage(message),
      // );

      // print("done");
      UserData userData = await AuthService().getUserData(uid: uid);
      context.read<UserDataProvider>().userData = userData;
    } catch (e) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ScreenList()),
        (route) => false);
  }
}
