import 'package:campusmate/db_test.dart';
import 'package:campusmate/firebase_test.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/screens/post_screen.dart';
import 'package:campusmate/screens/profile/profile_setting_a.dart';
import 'package:campusmate/screens/profile/profile_setting_b.dart';
import 'package:campusmate/screens/profile/profile_setting_c.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/login_screen.dart';

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
    MobileAds.instance.initialize();
    FirebaseTest().initFirebase();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            /// MainScreen
            ListTile(
              title: const Text("MainScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
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

            /// PSA
            ListTile(
              title: const Text("PSA", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileSettingA(
                          userData: UserData(),
                        )),
              ),
            ),

            /// PSB
            ListTile(
              title: const Text("PSB", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileSettingB(
                          userData: UserData(),
                        )),
              ),
            ),

            /// PSC
            ListTile(
              title: const Text("PSC", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileSettingC(
                          userData: UserData(),
                        )),
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

            // PostScreen
            ListTile(
              title: const Text("PostScreen", style: TextStyle(fontSize: 24)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
