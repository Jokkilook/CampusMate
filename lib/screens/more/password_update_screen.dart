import 'dart:convert';

import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/widgets/input_text_field.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordUpdateScreen extends StatefulWidget {
  const PasswordUpdateScreen({super.key});

  @override
  State<PasswordUpdateScreen> createState() => _PasswordUpdateScreenState();
}

class _PasswordUpdateScreenState extends State<PasswordUpdateScreen> {
  late final TextEditingController originController;
  late final TextEditingController updateController;
  late final TextEditingController checkController;

  @override
  void initState() {
    super.initState();
    originController = TextEditingController();
    updateController = TextEditingController();
    checkController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("비밀번호 변경"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("현재 비밀번호"),
            const SizedBox(height: 10),
            InputTextField(
              obscrueSee: true,
              obscureText: true,
              isDark: isDark,
              controller: originController,
              hintText: "현재 비밀번호를 입력하세요.",
            ),
            const SizedBox(height: 20),
            const Text("변경할 비밀번호"),
            const SizedBox(height: 10),
            InputTextField(
              obscrueSee: true,
              obscureText: true,
              isDark: isDark,
              controller: updateController,
              hintText: "변경할 비밀번호를 입력하세요.",
            ),
            const SizedBox(height: 20),
            const Text("변경할 비밀번호 확인"),
            const SizedBox(height: 10),
            InputTextField(
              obscrueSee: true,
              obscureText: true,
              checkWithOther: true,
              checkongController: updateController,
              isDark: isDark,
              controller: checkController,
              hintText: "변경할 비밀번호를 다시 한번 입력하세요.",
            ),
            const SizedBox(height: 40),
            BottomButton(
              onPressed: () async {
                UserData userData = context.read<UserDataProvider>().userData;
                String message = "";
                String email = context.read<UserDataProvider>().userData.email!;
                String originPw = userData.password!;
                String inputOriginPw = sha256
                    .convert(utf8.encode(originController.value.text))
                    .toString();
                String updatePw = sha256
                    .convert(utf8.encode(updateController.value.text))
                    .toString();
                String checkPw = sha256
                    .convert(utf8.encode(checkController.value.text))
                    .toString();

                //빈칸 확인
                if (originController.value.text == "") {
                  message = "현재 비밀번호를 입력해주세요.";
                  showSnackBar(context, message);
                  return;
                }
                if (updateController.value.text == "") {
                  message = "변경할 비밀번호를 입력해주세요.";
                  showSnackBar(context, message);
                  return;
                }
                if (checkController.value.text == "") {
                  message = "변경할 비밀번호 확인을 입력해주세요.";
                  showSnackBar(context, message);
                  return;
                }

                //유효성 확인
                if (originPw != inputOriginPw) {
                  message = "현재 비밀번호가 틀립니다.";
                  showSnackBar(context, message);
                  return;
                }
                if (updatePw != checkPw) {
                  message = "변경할 비밀번호가 일치하지 않습니다.";
                  showSnackBar(context, message);
                  return;
                }
                if (originPw == checkPw) {
                  message = "변경할 비밀번호와 현재 비밀번호가 같습니다.";
                  showSnackBar(context, message);
                  return;
                }

                //변경시퀀스 실행
                await AuthService()
                    .changePassword(userData.uid!, email, originPw, checkPw);
                context.read<UserDataProvider>().userData.password = checkPw;
                Navigator.pop(context);
                message = "비밀번호가 변경되었습니다.";
                showSnackBar(context, message);
              },
              isCompleted: true,
              text: "비밀번호 변경",
              padding: const EdgeInsets.all(0),
            )
          ],
        ),
      ),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      backgroundColor: Colors.black.withOpacity(0.8),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(milliseconds: 2500),
    ));
  }
}
