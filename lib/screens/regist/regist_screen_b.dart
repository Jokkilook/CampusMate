import 'dart:async';

import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/otp.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/regist/regist_screen_c.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:provider/provider.dart';

///회원 가입 B : 이메일 입력 & 인증
//ignore: must_be_immutable
class RegistScreenB extends StatefulWidget {
  RegistScreenB({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  //이메일 보낼 SMTP 서버 설정 현재 지메일 사용, 지메일 계정에서 발급받은 앱 비밀번호
  final email = gmail("tjddbs8295@gmail.com", "neptioqcjjvsudfw");

  Future<bool> sending(String otp) async {
    var message = Message()
      ..from = const Address('campusmate@team.com', "캠퍼스메이트 인증코드")
      ..recipients.add(emailController.value.text)
      ..subject = "캠퍼스 메이트 인증코드"
      ..text = "캠퍼스 메이트 인증코드 : [ $otp ]\n3분 이내에 입력해주세요.";

    try {
      await send(message, email);
      return true;
    } on MailerException catch (e) {
      debugPrint(e.message);
      return false;
    }
  }

  final otp = OTP();
  int time = 180;

  @override
  State<RegistScreenB> createState() => _RegistScreenBState();
}

class _RegistScreenBState extends State<RegistScreenB> {
  late String inputEmail; //이메일 입력받을 변수
  late String inputCode;
  bool isCompleted = false;
  bool isSended = false;
  bool isLoading = false;
  bool isCorrect = true;
  String message = "";
  late Timer timer;

  @override
  void initState() {
    super.initState();
    inputEmail = "";
    inputCode = "";
    setState(() {});
  }

  bool emailCheck(String email) {
    if (email.contains(".ac.kr")) {
      return true;
    }
    return false;
  }

  void startTimer() {
    timer.cancel();
    widget.time = 180;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.time > 0) {
        widget.time--;
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  String secondToString(int time) {
    int minute = time ~/ 60;
    int second = time % 60;

    return "${minute < 10 ? ("0$minute") : minute}:${second < 10 ? ("0$second") : second}";
  }

  @override
  Widget build(BuildContext context) {
    final UserData newUserData = context.read<UserDataProvider>().userData;
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
                    builder: (context) => const LoginScreen(),
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
              color: isDark ? AppColors.darkTitle : AppColors.lightTitle),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 60,
                child: Container(
                  height: 10,
                  color: Colors.green,
                ),
              ),
              Expanded(
                flex: 30,
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
                        // 이메일 인증번호 섹션 , 다음 버튼 미포함
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "   학교 이메일 인증",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkHeadText
                                      : AppColors.lightHeadText,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                message,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.alertText),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          FractionallySizedBox(
                            widthFactor: 1,
                            child: SizedBox(
                              height: 50,
                              child: TextField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                readOnly: isCompleted,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  if (widget.emailController.value.text == "") {
                                    message = "";
                                  }
                                  setState(() {});
                                },
                                controller: widget.emailController,
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
                                    hintText: "학교 이메일을 입력하세요.",
                                    hintStyle: const TextStyle(fontSize: 13),
                                    labelStyle: const TextStyle(fontSize: 14),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10)),
                              ),
                            ),
                          ),
                          Text(
                            "   메일 하나당 하나의 계정만 가입 가능합니다.",
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: widget.emailController.value.text !=
                                        "" &&
                                    emailCheck(
                                        widget.emailController.value.text)
                                ? () async {
                                    startTimer();
                                    //이미 가입된 아이디가 있나 확인
                                    if (!(await AuthService()
                                        .checkDuplicatedEmail(
                                            email: widget
                                                .emailController.value.text,
                                            school:
                                                newUserData.school ?? ""))) {
                                      message = "이미 존재하는 이메일입니다!";
                                      setState(() {});
                                      return;
                                    }
                                    message = "";

                                    /* 인증번호 발송 버튼을 누르면 메일로 발송하는 코드 */
                                    setState(() {
                                      isLoading = true;
                                    });

                                    await widget
                                        .sending(widget.otp.createOTP(6));
                                    isSended = true;
                                    widget.otp.timerActivate();

                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                : null,
                            child: isLoading
                                ? const CircleLoading()
                                : Text(
                                    isSended ? "재발송" : "인증번호 발송 ",
                                    style: TextStyle(
                                        color: inputEmail.isNotEmpty
                                            ? AppColors.buttonText
                                            : Colors.black45,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.button,
                              minimumSize: const Size(10000, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          Visibility(
                            visible: isSended,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSended ? "   아직 인증번호가 도착하지 않았나요?" : "",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.lightText),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 50,
                                  child: TextField(
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    keyboardType: TextInputType.number,
                                    readOnly: isCompleted,
                                    controller: widget.codeController,
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: isDark
                                                  ? AppColors.darkLine
                                                  : AppColors.lightLine,
                                              width: 1.5,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                        hintText: "인증번호를 입력하세요.",
                                        hintStyle:
                                            const TextStyle(fontSize: 13),
                                        labelStyle:
                                            const TextStyle(fontSize: 14),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10)),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("   ${secondToString(widget.time)}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText)),
                                    Text(isCorrect ? "" : "인증코드가 일지하지 않습니다!   ",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red.shade800))
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: isCompleted
                                      ? null
                                      : () {
                                          /* 인증번호 확인 */
                                          if (widget.otp.verifyOTP(widget
                                              .codeController.value.text)) {
                                            isCompleted = true;
                                            isCorrect = true;
                                          } else {
                                            isCorrect = false;
                                          }

                                          setState(() {});
                                        },
                                  child: Text(
                                    "확인",
                                    style: TextStyle(
                                        color: isCompleted
                                            ? null
                                            : AppColors.buttonText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    minimumSize: const Size(10000, 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )
                              ],
                            ),
                          ),
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
        //아무 이메일로나 가입하려면 isCompleted: 와 onPressed: 를 true 로 수정, 배포할땐 isCompleted 변수로 설정
        isCompleted: isCompleted,
        onPressed: isCompleted
            ? () {
                /* 회원가입 데이터에 이메일 저장 후 다음 거로 */
                newUserData.email = widget.emailController.value.text;
                context.read<UserDataProvider>().userData = newUserData;

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistScreenC(),
                    ));
              }
            : null,
      ),
    );
  }
}
