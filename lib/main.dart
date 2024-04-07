import 'package:campusmate/db_test.dart';
import 'package:campusmate/firebase_test.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/media_data_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/screens/post_screen.dart';
import 'package:campusmate/screens/regist/regist_screen_c.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    MobileAds.instance.initialize();
    FirebaseTest().initFirebase();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => UserDataProvider(userData: UserData())),
        ChangeNotifierProvider(
          create: (context) => MediaDataProvider(),
        )
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ScreenList(),
      ),
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
