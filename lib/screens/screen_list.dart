import 'package:campusmate/screens/notification_test_screen.dart';
import 'package:campusmate/services/school_service.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/screens/profile/profile_setting_a.dart';
import 'package:campusmate/screens/profile/profile_setting_b.dart';
import 'package:campusmate/screens/profile/profile_setting_c.dart';
import 'package:campusmate/screens/profile/profile_setting_result.dart';
import 'package:campusmate/screens/regist/regist_result.dart';
import 'package:campusmate/screens/regist/regist_screen_a.dart';
import 'package:campusmate/screens/regist/regist_screen_b.dart';
import 'package:campusmate/screens/regist/regist_screen_c.dart';
import 'package:flutter/material.dart';

class ScreenList extends StatelessWidget {
  const ScreenList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("개발자 메뉴"),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            /// MainScreen
            ListTile(
              title: const Text("MainScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              ),
            ),
            const Divider(height: 0),

            /// LoginScreen
            ListTile(
              title: const Text("LoginScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
            const Divider(height: 0),

            /// REGISTA
            ListTile(
              title: const Text("REGISTA", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistScreenA()),
              ),
            ),
            const Divider(height: 0),

            /// REGISTB
            ListTile(
              title: const Text("REGISTB", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegistScreenB()),
              ),
            ),
            const Divider(height: 0),

            /// REGISTC
            ListTile(
              title: const Text("REGISTC", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegistScreenC()),
              ),
            ),
            const Divider(height: 0),

            /// REGIST RESULT
            ListTile(
              title:
                  const Text("REGIST RESULT", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegistResult(),
                ),
              ),
            ),
            const Divider(height: 0),

            /// PROFILEA
            ListTile(
              title: const Text("PROFILEA", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSettingA()),
              ),
            ),
            const Divider(height: 0),

            /// PROFILEB
            ListTile(
              title: const Text("PROFILEB", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSettingB()),
              ),
            ),
            const Divider(height: 0),

            /// PROFILEC
            ListTile(
              title: const Text("PROFILEC", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSettingC()),
              ),
            ),
            const Divider(height: 0),

            /// PROFILERESULT
            ListTile(
              title:
                  const Text("PROFILE RESULT", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSettingResult()),
              ),
            ),
            const Divider(height: 0),

            /// School Data Loading
            ListTile(
                title:
                    const Text("학교 이름 로딩 테스트", style: TextStyle(fontSize: 24)),
                onTap: () {
                  SchoolAPI().loadSchoolName();
                  //함부로 쓰면 안됌 파이어스토어 쓰기 작업 388번 수행하는 무시무시한 놈
                  //SchoolAPI().uploadSchoolInfo();
                }),
            const Divider(height: 0),

            /// Noti Test
            ListTile(
                title: const Text("알림 테스트 페이지", style: TextStyle(fontSize: 24)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationTestScreen(),
                      ));
                }),
            const Divider(height: 0),
          ],
        ),
      ),
    );
  }
}
