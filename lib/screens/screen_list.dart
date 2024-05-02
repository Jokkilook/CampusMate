import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
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
import 'package:provider/provider.dart';

class ScreenList extends StatelessWidget {
  const ScreenList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    UserData userData = context.read<UserDataProvider>().userData;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            /// MainScreen
            ListTile(
              title: const Text("MainScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => MainScreen(userData: userData)),
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

            /// REGISTA
            ListTile(
              title: const Text("REGISTA", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistScreenA()),
              ),
            ),

            /// REGISTB
            ListTile(
              title: const Text("REGISTB", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => RegistScreenB(
                          newUserData: UserData(),
                        )),
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

            /// REGIST RESULT
            ListTile(
              title:
                  const Text("REGIST RESULT", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RegistResult(
                    userData: UserData(),
                  ),
                ),
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

            /// PROFILERESULT
            ListTile(
              title:
                  const Text("PROFILE RESULT", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileSettingResult(userData: userData)),
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
