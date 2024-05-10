import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool isCheck = false;
  @override
  Widget build(BuildContext context) {
    UserData userData = context.read<UserDataProvider>().userData;
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원 탈퇴"),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkTag : AppColors.lightTag,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(15),
            child: Text(
              "1. 계정을 삭제하면 복구할 수 없습니다.\n2. 계정을 삭제해도 게시한 게시글, 댓글 등은 삭제되지 않습니다.\n3. ${userData.name} 님이 생성한 단체 채팅방은 자동으로 삭제되고 참여하고 계신 모든 채팅방에서 퇴장합니다.\n4. 채팅방에 보내신 메세지는 삭제되지 않습니다.\n5. 탈퇴 후 30일 동안 같은 이메일로 재가입 할 수 없습니다.",
              style: const TextStyle(fontSize: 18),
            ),
          ),
          CheckboxListTile(
            title: const Text("이해했습니다."),
            value: isCheck,
            onChanged: (value) {
              isCheck = value!;
              setState(() {});
            },
          ),
          TextButton(
              onPressed: isCheck
                  ? () {
                      if (!isCheck) return;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: IntrinsicHeight(
                                child: Column(
                                  children: [
                                    const Text(
                                      "계정이 영구히 삭제됩니다.",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    TextButton(
                                        onPressed: (() async {
                                          await AuthService()
                                              .deleteAccount(context, userData);
                                        }),
                                        child: const Text(
                                          "삭제하기",
                                          style: TextStyle(
                                              color: AppColors.alertText),
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  : null,
              child: const Text(
                "탈퇴하기",
                style: TextStyle(color: AppColors.alertText),
              ))
        ],
      ),
    );
  }
}
