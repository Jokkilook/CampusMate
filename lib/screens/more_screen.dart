import 'package:campusmate/modules/post_generator.dart';
import 'package:campusmate/modules/user_generator.dart';
import 'package:campusmate/provider/chatting_data_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class MoreScreen extends StatelessWidget {
  MoreScreen({super.key});
  bool isGeneral = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${context.read<ChattingDataProvider>().chatListStream}"),
              Text("${userProvider.userData.name}"),
              TextButton(
                  onPressed: () => userProvider.setName("sadsa"),
                  child: const Text("push")),
              const Text("버튼 누르면 10개씩 생성됨"),
              ElevatedButton(
                onPressed: () {
                  UserGenerator().addDummyUser(10);
                },
                child: const Text("더미유저생성"),
              ),
              ElevatedButton(
                onPressed: () {
                  UserGenerator().deleteDummyUser(10);
                },
                child: const Text("더미유저삭제"),
              ),
              ToggleButtons(
                children: const [Text("일반"), Text("익명")],
                isSelected: [isGeneral, !isGeneral],
                onPressed: (index) {
                  switch (index) {
                    case 0:
                      isGeneral = true;
                      break;
                    case 1:
                      isGeneral = false;
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  PostGenerator().addDummyPost(10, isGeneral: isGeneral);
                },
                child: const Text("더미포스트생성"),
              ),
              ElevatedButton(
                onPressed: () {
                  PostGenerator().deleteDummyPost(10, isGeneral: isGeneral);
                },
                child: const Text("더미포스트삭제"),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance
                      .signOut()
                      .whenComplete(() => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (route) => false));
                },
                child: const Text("로그아웃"),
              ),
            ],
          ),
        );
      },
    );
  }
}
