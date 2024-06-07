import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              context.pushNamed(Screen.myInfo);
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_sharp),
            title: const Text("앱 테마"),
            onTap: () {
              context.pushNamed(Screen.themeSetting);
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
        ],
      ),
    );
  }
}
