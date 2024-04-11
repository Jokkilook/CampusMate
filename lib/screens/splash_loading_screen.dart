import 'package:campusmate/firebase_options.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/chatting_data_provider.dart';
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
    // TODO: implement initState
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void getChattingInitData() async {}

  void initialize() async {
    String uid;
    //광고 로드
    await MobileAds.instance.initialize();

    try {
      //파이어베이스 연결
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).whenComplete(
        () async {
          uid = FirebaseAuth.instance.currentUser!.uid;
          //연결 완료하면 파이어스토어에서 유저 데이터 가져오기 시도
          try {
            //처음엔 캐시 데이터에서 찾기
            var snapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get(const GetOptions(source: Source.cache));
            var data = snapshot.data() as Map<String, dynamic>;
            var userData = UserData.fromJson(data);
            context.read<UserDataProvider>().userData = userData;
          } catch (e) {
            //캐시가 없으면 파이어스토어에서 로드
            var snapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();
            var data = snapshot.data() as Map<String, dynamic>;
            var userData = UserData.fromJson(data);
            context.read<UserDataProvider>().userData = userData;
            print(">>>>>>>>>>>>>>>>>>>>>>>>>>$e");
          }

          //유저 데이터 로드 후 채팅 리스트 데이터 로딩 시도
          try {
            //캐시 데이터 탐색
            context.read<ChattingDataProvider>().chatListInitData =
                await FirebaseFirestore.instance
                    .collection("chats")
                    .where("participantsUid",
                        arrayContains:
                            context.read<UserDataProvider>().userData.uid)
                    .get(const GetOptions(source: Source.cache));
          } on FirebaseException catch (e) {
            //없으면 파이어스토어에서 로드
            context.read<ChattingDataProvider>().chatListInitData =
                await FirebaseFirestore.instance
                    .collection("chats")
                    .where("participantsUid",
                        arrayContains:
                            context.read<UserDataProvider>().userData.uid)
                    .get();
            print(">>>>>>>>>>>>>>>>>>>>>>>>>>$e");
          }

          //채팅방 데이터 로딩 시도
          try {} catch (e) {}
        },
      );
    } catch (e) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>$e");
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ScreenList()),
        (route) => false);
  }
}
