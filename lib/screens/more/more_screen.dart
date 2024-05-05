import 'package:campusmate/AppColors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/modules/post_generator.dart';
import 'package:campusmate/modules/user_generator.dart';
import 'package:campusmate/screens/more/my_info_screen.dart';
import 'package:campusmate/screens/more/theme_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    super.initState();
    list = [isGeneral, !isGeneral];
  }

  @override
  Widget build(BuildContext context) {
    UserData userData = context.read<UserDataProvider>().userData;
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
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              "로그아웃",
              style: TextStyle(color: AppColors.alertText),
            ),
            onTap: () async {
              await AuthService().signOut(context);
            },
          ),
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userData.uid ?? ""),
                Text(userData.name ?? ""),
                Text(userData.email ?? ""),
                Text(userData.password ?? ""),
                Text(userData.gender ?? true ? "남자" : "여자"),
                Text(userData.registDate!.toDate().toString()),
                Text(userData.enterYear.toString() ?? ""),
                Text(userData.score.toString() ?? ""),
                Text(userData.tags.toString() ?? ""),
                Text(userData.school ?? ""),
                Text(userData.dept ?? ""),
                Text(userData.birthDate ?? ""),
                Text(userData.mbti ?? ""),
                Text(userData.introduce ?? ""),
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh))
          // ElevatedButton(
          //   onPressed: () {
          //     UserGenerator().addDummyUser(10);
          //   },
          //   child: const Text("더미유저생성"),
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     UserGenerator().deleteDummyUser(10);
          //   },
          //   child: const Text("더미유저삭제"),
          // ),
          // ToggleButtons(
          //   children: const [Text("일반"), Text("익명")],
          //   isSelected: list,
          //   onPressed: (index) {
          //     switch (index) {
          //       case 0:
          //         isGeneral = true;
          //         break;
          //       case 1:
          //         isGeneral = false;
          //         break;
          //     }
          //     setState(() {
          //       list = [isGeneral, !isGeneral];
          //     });
          //   },
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     PostGenerator().addDummyPost(context, 10, isGeneral: isGeneral);
          //   },
          //   child: const Text("더미포스트생성"),
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     PostGenerator()
          //         .deleteDummyPost(context, 10, isGeneral: isGeneral);
          //   },
          //   child: const Text("더미포스트삭제"),
          // ),
        ],
      ),
    );
  }
}
