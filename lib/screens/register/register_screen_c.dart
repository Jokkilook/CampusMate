import 'dart:convert';
import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/widgets/yest_no_dialog.dart';
import 'package:campusmate/widgets/input_text_field.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

///회원 가입 C : 비밀번호, 닉네임 입력
//ignore: must_be_immutable
class RegisterScreenC extends StatefulWidget {
  RegisterScreenC({super.key});

  bool pwObsecure = true;
  bool chObsecure = true;

  @override
  State<RegisterScreenC> createState() => _RegisterScreenCState();
}

class _RegisterScreenCState extends State<RegisterScreenC> {
  TextEditingController pwController = TextEditingController();
  TextEditingController pwConfirmController = TextEditingController();
  TextEditingController nickController = TextEditingController();

  bool isCompleted = false;
  bool isSended = false;
  bool isValid = true;
  bool isCorrect = false;
  bool checkStart = false;

  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    final UserData newUserData = context.read<UserDataProvider>().userData;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: (/* 로그인 화면으로 돌아가기 */) {
              showDialog(
                  context: context,
                  builder: (context) => YesNoDialog(
                        content: "지금 그만두면 처음부터 다시 해야해요!",
                        onYes: () => router.goNamed(Screen.login),
                      ));
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
                                    hintText: newUserData.email,
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
                          TextField(
                            onChanged: (value) {
                              isValid ? null : isValid = !isValid;
                              setState(() {});
                            },
                            obscureText: widget.pwObsecure,
                            controller: pwController,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                                suffixIcon: (pwController.value.text != "")
                                    ? IconButton(
                                        onPressed: () {
                                          widget.pwObsecure =
                                              !widget.pwObsecure;
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          widget.pwObsecure
                                              ? Icons.remove_red_eye
                                              : Icons.remove_red_eye_outlined,
                                          color: isDark
                                              ? AppColors.darkHint
                                              : AppColors.lightHint,
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 1,
                                        width: 1,
                                      ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: (!isValid)
                                          ? AppColors.alertText
                                          : isDark
                                              ? AppColors.darkLine
                                              : AppColors.lightLine,
                                      width: 1.5,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: (!isValid)
                                          ? AppColors.alertText
                                          : isDark
                                              ? AppColors.darkLine
                                              : AppColors.lightLine,
                                      width: 1.5,
                                    )),
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.darkInput
                                    : AppColors.lightInput,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: "사용할 비밀번호를 입력하세요.",
                                hintStyle: const TextStyle(fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10)),
                          ),
                          Text(
                            "  8자리 이상 영문, 숫자, 특수 문자를 포함해야 합니다.",
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText),
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
                          TextField(
                            onChanged: (value) {
                              setState(() {});
                            },
                            obscureText: widget.chObsecure,
                            controller: pwConfirmController,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                                suffixIcon: (pwConfirmController.value.text !=
                                        "")
                                    ? IconButton(
                                        onPressed: () {
                                          widget.chObsecure =
                                              !widget.chObsecure;
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          widget.chObsecure
                                              ? Icons.remove_red_eye
                                              : Icons.remove_red_eye_outlined,
                                          color: isDark
                                              ? AppColors.darkHint
                                              : AppColors.lightHint,
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 1,
                                        width: 1,
                                      ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: (pwController.value.text !=
                                                  pwConfirmController
                                                      .value.text &&
                                              pwConfirmController.value.text !=
                                                  "")
                                          ? AppColors.alertText
                                          : isDark
                                              ? AppColors.darkLine
                                              : AppColors.lightLine,
                                      width: 1.5,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: (pwController.value.text !=
                                                  pwConfirmController
                                                      .value.text &&
                                              pwConfirmController.value.text !=
                                                  "")
                                          ? AppColors.alertText
                                          : isDark
                                              ? AppColors.darkLine
                                              : AppColors.lightLine,
                                      width: 1.5,
                                    )),
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.darkInput
                                    : AppColors.lightInput,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: "사용할 비밀번호를 다시 한번 입력하세요.",
                                hintStyle: const TextStyle(fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10)),
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
                          InputTextField(
                              onChanged: () {
                                setState(() {});
                              },
                              maxLength: 20,
                              hintText: "사용할 닉네임을 입력하세요.",
                              isDark: isDark,
                              controller: nickController),
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
            pwController.value.text == pwConfirmController.value.text,
        onPressed: pwController.value.text.isNotEmpty &&
                nickController.value.text.isNotEmpty &&
                pwController.value.text == pwConfirmController.value.text
            ? () {
                //8자리 이상, 영문 숫자 특수문자 포함이 아니면
                if (!checkValidPassword(pwConfirmController.value.text)) {
                  isValid = false;
                  setState(() {});
                  return;
                }
                newUserData.name = nickController.value.text;
                // 비밀번호 암호화 후 삽입
                newUserData.password = sha256
                    .convert(utf8.encode(pwConfirmController.value.text))
                    .toString();

                context.goNamed(Screen.registerResult);
              }
            : null,
      ),
    );
  }

  bool checkValidPassword(String password) {
    String pattern =
        r'^(?=.*[a-zA-z])(?=.*[0-9])(?=.*[$`~!@$!%*#^?&\\(\\)\-_=+]).{8,}$';

    RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(password)) return false;

    return true;
  }
}
