import 'dart:convert';
import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/screens/regist/regist_screen_a.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();

  final TextEditingController pwContorller = TextEditingController();

  final firebaseAuth = FirebaseAuth.instance;

  bool idEmpty = false;
  bool pwEmpty = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        idEmpty
                            ? const Text(
                                "   아이디를 입력해주세요!",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.alertText,
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 15),
                        //비밀번호 입력칸
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              controller: pwContorller,
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
                        pwEmpty
                            ? const Text(
                                "   비밀번호를 입력해주세요!",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.alertText,
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 15),
                      ],
                    ),
                    ElevatedButton(
                      child: isLoading
                          ? CircleLoading(
                              color: Colors.green[900]!,
                            )
                          : const Text(
                              "로그인",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.buttonText,
                                  fontSize: 18),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.button,
                        minimumSize: const Size(1000, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        idEmpty = false;
                        pwEmpty = false;
                        //아이디 비번이 공란이 아닐 때
                        if (idController.value.text != "" &&
                            pwContorller.value.text != "") {
                          setState(() {
                            isLoading = true;
                          });

                          //이메일 저장, 비밀번호 암호화 후 저장
                          String email = idController.value.text;
                          String password = sha256
                              .convert(utf8.encode(pwContorller.value.text))
                              .toString();

                          //로그인 시도
                          await firebaseAuth
                              .signInWithEmailAndPassword(
                                  email: email, password: password)
                              //로그인 성공 시
                              .then((value) async {
                            //파이어베이스에서 유저 정보 불러오고 프로바이더에 저장 후 메인 페이지로 이동
                            await AuthService()
                                .getUserData(uid: firebaseAuth.currentUser!.uid)
                                .then(
                              (value) {
                                UserData userData = value;
                                context.read<UserDataProvider>().userData =
                                    userData;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                            );
                          })
                              //로그인 실패 시
                              .catchError((error) {
                            setState(() {
                              isLoading = false;
                            });
                            String message = "로그인에 실패했습니다.";
                            switch (error.code) {
                              //이메일 형식이 입력되지 않음
                              case "invalid-email":
                                message = "아이디는 학교 이메일 형식입니다.";
                                break;
                              //일치하는 정보가 없음
                              case "invalid-credential":
                                message = "이메일이나 비밀번호가 틀립니다.";
                                break;
                              default:
                                message = "로그인에 실패했습니다. 잠시 후 다시 시도해주세요.";
                                break;
                            }
                            //실패 이유에 따른 스낵바 출력
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                elevation: 0,
                                backgroundColor: Colors.black.withOpacity(0.8),
                                content: Text(
                                  message,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                duration: const Duration(milliseconds: 1500),
                              ),
                            );
                          });
                        } else {
                          //아이디가 비어있으면
                          if (idController.value.text == "") {
                            idEmpty = true;
                          }
                          //비밀번호가 비어있으면
                          if (pwContorller.value.text == "") {
                            pwEmpty = true;
                          }
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      style: const ButtonStyle(
                          overlayColor:
                              MaterialStatePropertyAll(Colors.transparent)),
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
                            color: AppColors.button,
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
