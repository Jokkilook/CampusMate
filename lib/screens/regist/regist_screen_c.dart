import 'dart:convert';
import 'package:campusmate/AppColors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/regist/regist_result.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistScreenC extends StatefulWidget {
  const RegistScreenC({super.key, required this.newUserData});

  final UserData newUserData;

  @override
  State<RegistScreenC> createState() => _RegistScreenCState();
}

class _RegistScreenCState extends State<RegistScreenC> {
  TextEditingController pwController = TextEditingController();
  TextEditingController pwConfirmController = TextEditingController();
  TextEditingController nickController = TextEditingController();

  bool isCompleted = false;
  bool isSended = false;
  bool isCorrect = false;
  bool checkStart = false;

  final auth = FirebaseAuth.instance;
  final db = DataBase();

  @override
  void initState() {
    super.initState();
    //유저 데이터에 저장된 이메일 가져오기

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: (/* 로그인 화면으로 돌아가기 */) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (route) => false);
            },
            icon: const Icon(Icons.close),
          )
        ],
        title: Text(
          "회원가입",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 100,
                child: Container(
                  height: 10,
                  color: Colors.green,
                ),
              ),
              Expanded(
                flex: 00,
                child: Container(
                  height: 10,
                  color: isDark ? AppColors.darkTag : AppColors.lightTag,
                ),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("   아이디",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkHeadText
                                    : AppColors.lightHeadText,
                              )),
                          const SizedBox(height: 5),
                          FractionallySizedBox(
                            widthFactor: 1,
                            child: SizedBox(
                              height: 50,
                              child: TextField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                readOnly: true,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.darkLine
                                              : AppColors.lightLine,
                                          width: 1.5,
                                        )),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.darkLine
                                              : AppColors.lightLine,
                                          width: 1.5,
                                        )),
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.darkInput
                                        : AppColors.lightInput,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: widget.newUserData.email,
                                    labelStyle: const TextStyle(fontSize: 14),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text("   비밀번호",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkHeadText
                                    : AppColors.lightHeadText,
                              )),
                          const SizedBox(height: 5),
                          FractionallySizedBox(
                            widthFactor: 1,
                            child: SizedBox(
                              height: 50,
                              child: TextField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                controller: pwController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.darkLine
                                              : AppColors.lightLine,
                                          width: 1.5,
                                        )),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.darkLine
                                              : AppColors.lightLine,
                                          width: 1.5,
                                        )),
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.darkInput
                                        : AppColors.lightInput,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: "사용할 비밀번호를 입력하세요.",
                                    hintStyle: const TextStyle(fontSize: 13),
                                    labelStyle: const TextStyle(fontSize: 14),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text("   비밀번호 확인",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkHeadText
                                    : AppColors.lightHeadText,
                              )),
                          const SizedBox(height: 5),
                          FractionallySizedBox(
                            widthFactor: 1,
                            child: SizedBox(
                              height: 50,
                              child: TextField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onChanged: (value) {
                                  if (pwController.value.text ==
                                      pwConfirmController.value.text) {
                                    isCorrect = true;
                                  } else {
                                    isCorrect = false;
                                  }
                                  setState(() {});
                                },
                                controller: pwConfirmController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: pwConfirmController
                                                      .value.text.isEmpty ||
                                                  isCorrect
                                              ? (isDark
                                                  ? AppColors.darkLine
                                                  : AppColors.lightLine)
                                              : Colors.red.shade600,
                                          width: 1.5,
                                        )),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: pwConfirmController
                                                      .value.text.isEmpty ||
                                                  isCorrect
                                              ? (isDark
                                                  ? AppColors.darkLine
                                                  : AppColors.lightLine)
                                              : Colors.red.shade600,
                                          width: 1.5,
                                        )),
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.darkInput
                                        : AppColors.lightInput,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: "사용할 비밀번호를 다시 한번 입력하세요.",
                                    hintStyle: const TextStyle(fontSize: 13),
                                    labelStyle: const TextStyle(fontSize: 14),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text("   닉네임",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkHeadText
                                    : AppColors.lightHeadText,
                              )),
                          const SizedBox(height: 5),
                          FractionallySizedBox(
                            widthFactor: 1,
                            child: SizedBox(
                              height: 70,
                              child: TextField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                maxLength: 20,
                                controller: nickController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.darkLine
                                              : AppColors.lightLine,
                                          width: 1.5,
                                        )),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.darkLine
                                              : AppColors.lightLine,
                                          width: 1.5,
                                        )),
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.darkInput
                                        : AppColors.lightInput,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: "사용할 닉네임을 입력하세요.",
                                    hintStyle: const TextStyle(fontSize: 13),
                                    labelStyle: const TextStyle(fontSize: 14),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomButton(
        text: "다음",
        isCompleted: pwController.value.text.isNotEmpty &&
            nickController.value.text.isNotEmpty &&
            isCorrect,
        onPressed: pwController.value.text.isNotEmpty &&
                nickController.value.text.isNotEmpty &&
                isCorrect
            ? () {
                /* 회원가입 데이터에 나머지 저장 후 데이터베이스에 삽입 */
                widget.newUserData.name = nickController.value.text;
                // 비밀번호 암호화 후 삽입
                widget.newUserData.password = sha256
                    .convert(utf8.encode(pwConfirmController.value.text))
                    .toString();

                registAndLogin();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RegistResult(userData: widget.newUserData),
                    ));
              }
            : null,
      ),
    );
  }

  void registAndLogin() async {
    await auth.createUserWithEmailAndPassword(
        email: widget.newUserData.email.toString(),
        password: widget.newUserData.password.toString());
    try {
      await auth.signInWithEmailAndPassword(
          email: widget.newUserData.email.toString(),
          password: widget.newUserData.password.toString());
      widget.newUserData.uid = auth.currentUser!.uid;
      widget.newUserData.registDate = Timestamp.fromDate(DateTime.now());
      AuthService().registUser(widget.newUserData);
      //db.addUser(widget.newUserData);
    } catch (e) {
      throw Error();
    }
  }

  void login() async {
    try {
      await auth.signInWithEmailAndPassword(
          email: widget.newUserData.email.toString(),
          password: widget.newUserData.password.toString());
    } catch (e) {}
  }
}
