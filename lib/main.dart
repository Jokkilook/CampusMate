import 'package:campusmate/screens/profile_setting_a.dart';
import 'package:campusmate/screens/profile_setting_b.dart';
import 'package:campusmate/screens/profile_setting_c.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/regist_screen_a.dart';
import 'screens/regist_screen_b.dart';
import 'screens/regist_screen_c.dart';
import 'screens/general_board.dart';
import 'screens/profil_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScreenList(),
    );
  }
}

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
            /// LoginScreen
            ListTile(
              title: const Text("LoginScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),

            /// RegistScreenA
            ListTile(
              title:
                  const Text("RegistScreenA", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistScreenA()),
              ),
            ),

            /// RegistScreenB
            ListTile(
              title:
                  const Text("RegistScreenB", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistScreenB()),
              ),
            ),

            /// RegistScreenC
            ListTile(
              title:
                  const Text("RegistScreenC", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistScreenC()),
              ),
            ),

            /// ProfileSettingA
            ListTile(
              title:
                  const Text("ProfileSettingA", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSettingA()),
              ),
            ),

            /// ProfileSettingB
            ListTile(
              title:
                  const Text("ProfileSettingB", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSettingB()),
              ),
            ),

            /// ProfileSettingC
            ListTile(
              title:
                  const Text("ProfileSettingC", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSettingC()),
              ),
            ),

            /// ProfilScreen
            ListTile(
              title: const Text("ProfilScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilScreen()),
              ),
            ),

            /// GeneralBoard
            ListTile(
              title: const Text("GeneralBoard", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GeneralBoard()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
