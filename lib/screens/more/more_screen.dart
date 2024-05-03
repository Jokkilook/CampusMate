import 'package:campusmate/screens/community/modules/post_generator.dart';
import 'package:campusmate/modules/user_generator.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/more/my_info_screen.dart';
import 'package:campusmate/screens/more/theme_setting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool isGeneral = true;
  late List<bool> list;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list = [isGeneral, !isGeneral];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("더보기"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("내 정보"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyInfoScreen(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_brightness),
            title: const Text("앱 테마"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThemeSettingScreen(),
                  ));
            },
          ),
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
            isSelected: list,
            onPressed: (index) {
              switch (index) {
                case 0:
                  isGeneral = true;
                  break;
                case 1:
                  isGeneral = false;
                  break;
              }
              setState(() {
                list = [isGeneral, !isGeneral];
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              PostGenerator().addDummyPost(context, 10, isGeneral: isGeneral);
            },
            child: const Text("더미포스트생성"),
          ),
          ElevatedButton(
            onPressed: () {
              PostGenerator()
                  .deleteDummyPost(context, 10, isGeneral: isGeneral);
            },
            child: const Text("더미포스트삭제"),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().whenComplete(
                () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                      (route) => false);
                },
              );
            },
            child: const Text("로그아웃"),
          ),
        ],
      ),
    );
  }
}
