import 'dart:convert';

import 'package:campusmate/AppColors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/chatting_data_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/screens/regist/regist_screen_a.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController idController = TextEditingController();
  final TextEditingController pwContorlloer = TextEditingController();
  final firebaseAuth = FirebaseAuth.instance;
  final db = DataBase();
  late final UserData userData;

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    Future<bool> login() async {
      try {
        await firebaseAuth.signInWithEmailAndPassword(
            email: idController.value.text,
            password: sha256
                .convert(utf8.encode(pwContorlloer.value.text))
                .toString());

        //채팅데이터프로바이더에 채팅리스트 스트림 로드
        context.read<ChattingDataProvider>().chatListStream = FirebaseFirestore
            .instance
            .collection("chats")
            .where("participantsUid",
                arrayContains: context.read<UserDataProvider>().userData.uid)
            .snapshots();
        return true;
      } catch (e) {
        return false;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Column(
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "학교에서 친구찾기",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF838383)),
                        ),
                        Text(
                          "캠퍼스 메이트",
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF838383)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                    //아이디 입력칸
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: idController,
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkLine
                                      : AppColors.lightLine,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkLine
                                      : AppColors.lightLine,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.darkInput
                                  : AppColors.lightInput,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              label: Text("아이디",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkHint
                                          : AppColors.lightHint)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    //비밀번호 입력칸
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: pwContorlloer,
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkLine
                                      : AppColors.lightLine,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkLine
                                      : AppColors.lightLine,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.darkInput
                                  : AppColors.lightInput,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              label: const Text(
                                "비밀번호",
                              ),
                              labelStyle: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkHint
                                      : AppColors.lightHint),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        //UserData userData;
                        FocusManager.instance.primaryFocus?.unfocus();
                        login().then((value) async {
                          if (value) {
                            await AuthService()
                                .getUserData(uid: firebaseAuth.currentUser!.uid)
                                .then((value) {
                              userData = value;
                              context.read<UserDataProvider>().userData =
                                  userData;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MainScreen(userData: userData),
                                ),
                                (route) => false,
                              );
                            });
                          } else {}
                        });
                      },
                      child: const Text(
                        "로그인",
                        style:
                            TextStyle(color: Color(0xFF0A351E), fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2BB56B),
                        minimumSize: const Size(1000, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegistScreenA(),
                            ));
                      },
                      child: const Text(
                        "회원가입",
                        style: TextStyle(
                            color: Color(0xFF0A351E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
