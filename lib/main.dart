import 'package:campusmate/db_test.dart';
import 'package:campusmate/firebase_test.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/profile/profile_setting_a.dart';
import 'package:campusmate/screens/profile/profile_setting_b.dart';
import 'package:campusmate/screens/profile/profile_setting_c.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/regist/regist_screen_a.dart';
import 'screens/community_screen.dart';
import 'screens/profile/profile_screen.dart';

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
    FirebaseTest().initFirebase();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            /// LoginScreen
            ListTile(
              title: const Text("LoginScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              ),
            ),

            /// RegistScreenA
            ListTile(
              title:
                  const Text("Regist Sequence", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistScreenA()),
              ),
            ),

            /// ProfileSettingA
            ListTile(
              title:
                  const Text("ProfileSettingA", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileSettingA(userData: UserData())),
              ),
            ),

            /// ProfileSettingB
            ListTile(
              title:
                  const Text("ProfileSettingB", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileSettingB(userData: UserData())),
              ),
            ),

            /// ProfileSettingC
            ListTile(
              title:
                  const Text("ProfileSettingC", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileSettingC(userData: UserData())),
              ),
            ),

            /// ProfilScreen
            ListTile(
              title: const Text("ProfilScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilScreen()),
              ),
            ),

            /// CommunityScreen
            ListTile(
              title:
                  const Text("CommunityScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunityScreen()),
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
          ],
        ),
      ),
    );
  }
}
