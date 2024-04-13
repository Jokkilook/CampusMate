import 'package:campusmate/db_test.dart';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/chatting/chat_room_screen.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/screens/profile/profile_setting_a.dart';
import 'package:campusmate/screens/profile/profile_setting_b.dart';
import 'package:campusmate/screens/profile/profile_setting_c.dart';
import 'package:campusmate/screens/regist/regist_screen_c.dart';
import 'package:flutter/material.dart';

class ScreenList extends StatelessWidget {
  const ScreenList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            /// LoginScreen
            ListTile(
              title: const Text("LoginScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              ),
            ),

            /// REGISTC
            ListTile(
              title: const Text("REGISTC", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => RegistScreenC(
                          newUserData: UserData(),
                        )),
              ),
            ),

            /// PROFILEA
            ListTile(
              title: const Text("PROFILEA", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileSettingA(userData: UserData())),
              ),
            ),

            /// PROFILEB
            ListTile(
              title: const Text("PROFILEB", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileSettingB(userData: UserData())),
              ),
            ),

            /// PROFILEC
            ListTile(
              title: const Text("PROFILEC", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileSettingC(userData: UserData())),
              ),
            ),

            /// DB TEST
            ListTile(
              title: const Text("DB TEST", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DBTest()),
              ),
            ),

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
          ],
        ),
      ),
    );
  }
}
