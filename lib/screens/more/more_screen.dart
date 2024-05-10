import 'package:campusmate/app_colors.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/more/my_info_screen.dart';
import 'package:campusmate/screens/more/theme_setting_screen.dart';
import 'package:campusmate/screens/screen_list.dart';
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
            leading: const Icon(Icons.code),
            title: const Text("개발자 메뉴"),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreenList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
