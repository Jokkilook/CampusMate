import 'dart:convert';

import 'package:campusmate/models/schedule_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/regist_screen_a.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  TextEditingController idController = TextEditingController();
  TextEditingController pwContorlloer = TextEditingController();
  final firebaseAuth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final userData = UserData();

  void set() {
    userData.name = "jo";
    userData.age = 24;
    userData.dept = "테스트학과";
    userData.email = "ppkw2001@gmail.com";
    userData.password = sha256.convert(utf8.encode("qkrrhksdn")).toString();
    userData.enterYear = 2020;
    userData.gender = true;
    userData.schedule = ScheduleData();
  }

  @override
  Widget build(BuildContext context) {
    set();

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xFFEDF2F1),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "학교에서 친구찾기",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF838383)),
                        ),
                        const Text(
                          "캠퍼스 메이트",
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF838383)),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              firebaseAuth.signInWithEmailAndPassword(
                                  email: userData.email!,
                                  password: userData.password!);
                              print(firebaseAuth.currentUser!.uid);
                              db
                                  .collection("test")
                                  .doc("tests")
                                  .set(userData.data!)
                                  .onError((error, stackTrace) =>
                                      print(error.toString()));
                            },
                            child: const Text("Auth Test"))
                      ],
                    ),
                    const SizedBox(height: 100),
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: idController,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black45,
                                    width: 2,
                                  )),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              label: const Text("아이디",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                              labelStyle: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: pwContorlloer,
                          obscureText: true,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black45,
                                    width: 2,
                                  )),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              label: const Text(
                                "비밀번호",
                              ),
                              labelStyle: const TextStyle(fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegistScreenA(),
                                  ));
                            },
                            child: const Text(
                              "회원가입",
                              style: TextStyle(
                                  color: Color(0xFF0A351E), fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2BB56B),
                              minimumSize: const Size(100, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              login();
                            },
                            child: const Text(
                              "로그인",
                              style: TextStyle(
                                  color: Color(0xFF0A351E), fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2BB56B),
                              minimumSize: const Size(100, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        )
                      ],
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

  void login() async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: idController.value.text,
          password:
              sha256.convert(utf8.encode(pwContorlloer.value.text)).toString());
    } catch (e) {}
  }
}
