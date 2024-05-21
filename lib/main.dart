import 'package:campusmate/app_colors.dart';
import 'package:campusmate/firebase_options.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/noti_test.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/provider/theme_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  //플러터 코어 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  //회전 방지 코드(세로화면 고정)
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  UserData? userData = await initializeFirebaseAndAds();
  bool isSignIn = (userData != null);
  ThemeMode currentThemeMode = await loadThemeMode();

  NotiTest.init();
  Future.delayed(
    const Duration(seconds: 3),
    () {
      NotiTest.requestNotiPermission();
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              UserDataProvider(userData: userData ?? UserData()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ThemeProvider(currentThemeMode: currentThemeMode),
        )
      ],
      child: MyApp(isSignIn: isSignIn),
    ),
  );
}

Future<UserData?> initializeFirebaseAndAds() async {
  UserData? returnUser;

  //광고 로드
  await MobileAds.instance.initialize();

  try {
    //파이어베이스 연결
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    //로그인된 유저가 없으면 유저 null 반환
    if (FirebaseAuth.instance.currentUser == null) {
      return returnUser;
    }
    //로그인 된 유저가 있으면 유저 데이터 반환
    else {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      return returnUser = await AuthService().getUserData(uid: uid ?? "");
    }
  } catch (e) {
    debugPrint(e.toString());
    return returnUser;
  }
}

Future<ThemeMode> loadThemeMode() async {
  ThemeMode returnTheme = ThemeMode.system;
  SharedPreferences pref = await SharedPreferences.getInstance();

  switch (pref.getString("theme")) {
    case "light":
      returnTheme = ThemeMode.light;
      break;
    case "dark":
      returnTheme = ThemeMode.dark;
      break;
    case "system":
      returnTheme = ThemeMode.system;
      break;
    default:
      returnTheme = ThemeMode.system;
      break;
  }

  return returnTheme;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.isSignIn = false});
  final bool isSignIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isSignIn ? const MainScreen() : const LoginScreen(),
      themeMode: Provider.of<ThemeProvider>(context).currentThemeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,
        dialogTheme: const DialogTheme(
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        indicatorColor: Colors.green,
        drawerTheme: DrawerThemeData(
          elevation: 0,
          backgroundColor: Colors.grey[100],
          scrimColor: Colors.black.withOpacity(0.4),
        ),
        appBarTheme: AppBarTheme(
            scrolledUnderElevation: 0,
            color: AppColors.lightAppbar,
            surfaceTintColor: Colors.transparent,
            shape:
                Border(bottom: BorderSide(width: 1, color: Colors.grey[400]!))),
        cardTheme: const CardTheme(color: Colors.white),
        scaffoldBackgroundColor: AppColors.lightBackground,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightBottomNavBar,
        ),
        badgeTheme: const BadgeThemeData(
          backgroundColor: Color.fromARGB(255, 230, 50, 50),
          textColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
        dialogTheme: const DialogTheme(
            surfaceTintColor: Colors.transparent, elevation: 0),
        indicatorColor: Colors.green,
        drawerTheme: DrawerThemeData(
          elevation: 0,
          backgroundColor: Colors.grey[850],
          scrimColor: Colors.black.withOpacity(0.4),
        ),
        appBarTheme: AppBarTheme(
            scrolledUnderElevation: 0,
            color: AppColors.darkAppbar,
            surfaceTintColor: Colors.transparent,
            shape:
                Border(bottom: BorderSide(width: 1, color: Colors.grey[800]!))),
        cardTheme: CardTheme(color: AppColors.darkCard),
        cardColor: Colors.grey[700],
        canvasColor: Colors.grey[600],
        scaffoldBackgroundColor: AppColors.darkBackground,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkBottomNavBar,
        ),
        badgeTheme: const BadgeThemeData(
          backgroundColor: Color.fromARGB(255, 230, 50, 50),
          textColor: Colors.white,
        ),
      ),
    );
  }
}
