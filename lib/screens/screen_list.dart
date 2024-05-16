import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/screens/chatting/chat_room_screen.dart';
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

            /// CHATROOM
            ListTile(
              title: const Text("CHATROOM", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatRoomScreen(
                          chatRoomData: ChatRoomData(),
                        )),
              ),
            ),
            const Divider(height: 0),
          ],
        ),
      ),
    );
  }
}
